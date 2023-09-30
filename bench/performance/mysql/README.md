# Performance benchmarks: PaperTail vs. Logidze

We want to compare Logidze with the most popular versioning library for Rails – PaperTrail.

Bench env:
- MacBook Pro 15 mid-2015 (2.20GHz Intel i7-4770HQ, 16GB, SSD)
- Rails 6.0
- PaperTrail 12.3.0
- Logidze 1.2.3
- MySQL 5.7

To run this benchmarks, you need to first provision the example Rails app:

```sh
bundle install
bundle exec rails db:environment:set RAILS_ENV=development
bundle exec rails db:create
bundle exec rails db:migrate
```

To run a benchmark, run the corresponding script:

```sh
bundle exec ruby benchmarks/insert_bench.rb
```

## Insert ([source](benchmarks/insert_bench.rb))

```sh
Comparison:
        Plain INSERT:       91.8 i/s
      Logidze INSERT:       87.5 i/s - same-ish: difference falls within error
   PaperTrail INSERT:       73.7 i/s - 1.25x  slower
```

## Update ([source](benchmarks/update_bench.rb))

When changeset has 2 fields:

```sh
Comparison:
     Plain UPDATE #2:       52.8 i/s
   Logidze UPDATE #2:       44.8 i/s - same-ish: difference falls within error
        PT UPDATE #2:       41.6 i/s - same-ish: difference falls within error
```

When changeset has 5 fields:

```sh
Comparison:
     Plain UPDATE #5:       15.3 i/s
   Logidze UPDATE #5:       13.7 i/s - same-ish: difference falls within error
        PT UPDATE #5:       12.4 i/s - same-ish: difference falls within error
```

## Getting diff ([source](benchmarks/diff_bench.rb))

PaperTrail doesn't have built-in method to calculate diff between not adjacent versions.
We added `#diff_from(ts)` and `#diff_from_joined(ts)` (which uses SQL JOIN) methods to calculate diff from specified version using changesets.

When each record has 10 versions:

```sh
Comparison:
        Logidze DIFF:      225.4 i/s
             PT DIFF:        2.4 i/s - 95.10x  slower
      PT (join) DIFF:        2.3 i/s - 99.62x  slower
```

When each record has 100 versions:

```sh
Comparison:
        Logidze DIFF:      219.0 i/s
             PT DIFF:        0.2 i/s - 915.90x  slower
      PT (join) DIFF:        0.2 i/s - 974.84x  slower
```

## Getting version at the specified time ([source](benchmarks/version_at_bench.rb))

Measuring the time to get the _middle_ version using the corresponding timestamp.

When each record has 10 versions:

```sh
Comparison:
   Logidze AT single:      553.0 i/s
        PT AT single:      174.0 i/s - 3.18x  slower

Comparison:
     Logidze AT many:      373.5 i/s
          PT AT many:       25.7 i/s - 14.51x  slower
```

When each record has 100 versions:

```sh
Comparison:
   Logidze AT single:      590.1 i/s
        PT AT single:      165.2 i/s - 3.57x  slower

Comparison:
     Logidze AT many:      360.6 i/s
          PT AT many:       22.0 i/s - 16.42x  slower
```

**NOTE:** PaperTrail has N+1 problem when loading multiple records at the specified time (due to the usage of the `versions.subsequent` method).

## Select memory usage ([source](benchmarks/memory_profile.rb))

Logidze stores logs in-place. But at what cost?

When each record has 10 versions:

```sh
Plain records
Total Allocated:				            28.7 KB
Total Retained:					            21.41 KB
Retained_memsize memory (per record):		1.54 KB

PT with versions
Total Allocated:				            268.79 KB
Total Retained:					            234.04 KB
Retained_memsize memory (per record):		207.07 KB

Logidze records
Total Allocated:				            30.65 KB
Total Retained:					            23.13 KB
Retained_memsize memory (per record):		2.79 KB
```

When each record has 100 versions:

```sh
Plain records
Total Allocated:				            29.02 KB
Total Retained:					            21.73 KB
Retained_memsize memory (per record):		1.66 KB

PT with versions
Total Allocated:				            2.31 MB
Total Retained:					            2.11 MB
Retained_memsize memory (per record):		2.09 MB

Logidze records
Total Allocated:				            30.85 KB
Total Retained:					            23.33 KB
Retained_memsize memory (per record):		2.83 KB
```

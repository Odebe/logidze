# frozen_string_literal: true

require "rspec/core/rake_task"

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  task(:rubocop) {}
end

RSpec::Core::RakeTask.new(:spec)

# https://github.com/paper-trail-gem/paper_trail/blob/master/Rakefile#L9
desc "Copy the database.DB.yml per ENV['DB']"
task :install_database_yml do
  # postgres, mysql
  puts format("installing database.yml for %s", ENV["DB"])

  FileUtils.cp(
    "spec/dummy/config/database.#{ENV['DB']}.yml",
    "spec/dummy/config/database.yml"
  )
end

namespace :dummy do
  require_relative "spec/dummy/config/application"
  Dummy::Application.load_tasks
end

task(:spec).clear
desc "Run specs other than spec/acceptance"
RSpec::Core::RakeTask.new("spec") do |task|
  task.exclude_pattern = "spec/acceptance/**/*_spec.rb"
  task.verbose = false
end

desc "Run acceptance specs in spec/acceptance"
RSpec::Core::RakeTask.new("spec:acceptance") do |task|
  task.pattern = "spec/acceptance/**/*_spec.rb"
  task.verbose = false
end

desc "Run the specs and acceptance tests"
task default: %w[rubocop spec spec:acceptance]

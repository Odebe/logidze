# frozen_string_literal: true

require "spec_helper"
require "generators/logidze/install/install_generator"

describe Logidze::Generators::InstallGenerator, type: :generator, database: :mysql2 do
  destination File.expand_path("../../../tmp", __dir__)

  let(:use_fx_args) { USE_FX ? [] : ["--fx"] }
  let(:fx_args) { USE_FX ? ["--no-fx"] : [] }

  let(:base_args) { [] }
  let(:args) { base_args + fx_args }
  let(:ar_version) { "6.0" }

  before do
    prepare_destination
    allow(ActiveRecord::Migration).to receive(:current_version).and_return(ar_version)
  end

  describe "trigger migration" do
    subject { migration_file("db/migrate/logidze_install.rb") }

    it "creates migration", :aggregate_failures do
      run_generator(args)

      is_expected.to exist
      is_expected.to contain "ActiveRecord::Migration[#{ar_version}]"
    end

    xcontext "when using fx" do
      let(:fx_args) { use_fx_args }

      it "creates migration", :aggregate_failures do
        run_generator(args)

        is_expected.to exist
        is_expected.to contain "ActiveRecord::Migration[#{ar_version}]"
      end

      it "creates function files" do
        run_generator(args)

        is_expected.to exist
        %w[
          logidze_logger_v04.sql
          logidze_logger_after_v04.sql
          logidze_version_v02.sql
          logidze_filter_keys_v01.sql
          logidze_snapshot_v03.sql
          logidze_compact_history_v01.sql
          logidze_capture_exception_v01.sql
        ].each do |path|
          expect(file("db/functions/#{path}")).to exist
        end
      end
    end
  end

  # xdescribe "hstore migration" do
  #   subject { migration_file("db/migrate/enable_hstore.rb") }
  #
  #   it "creates migration", :aggregate_failures do
  #     run_generator(args)
  #
  #     is_expected.to exist
  #     is_expected.to contain "ActiveRecord::Migration[#{ar_version}]"
  #   end
  # end

  xcontext "update migration" do
    let(:version) { Logidze::VERSION.delete(".") }
    let(:base_args) { ["--update"] }

    subject { migration_file("db/migrate/logidze_update_#{version}.rb") }

    it "creates only functions", :aggregate_failures do
      run_generator(args)

      expect(migration_file("db/migrate/logidze_install.rb")).not_to exist

      is_expected.to exist
    end

    context "when using fx" do
      let(:fx_args) { use_fx_args }

      let(:existing) do
        %w[
          logidze_version_v03.sql
          logidze_snapshot_v4.sql
          logidze_filter_keys_v01.sql
          logidze_compact_history_v05.sql
          logidze_logger_v7.sql
          logidze_logger_after_v7.sql
        ]
      end

      before do
        FileUtils.mkdir_p(file("db/functions"))
        existing.each do |path|
          File.write(file("db/functions/#{path}"), "")
        end
      end

      after do
        existing.each do |path|
          File.delete(file("db/functions/#{path}"))
        end

        FileUtils.rm_r(file("db/functions"))
      end

      it "creates migration", :aggregate_failures do
        run_generator(args)

        is_expected.to exist
      end

      it "creates function files" do
        run_generator(args)

        is_expected.to exist
        %w[
          logidze_logger_v04.sql
          logidze_logger_after_v04.sql
          logidze_version_v02.sql
          logidze_snapshot_v03.sql
          logidze_compact_history_v01.sql
          logidze_capture_exception_v01.sql
        ].each do |path|
          expect(file("db/functions/#{path}")).to exist
        end
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"
require "generators/logidze/install/install_generator"

describe Logidze::Generators::InstallGenerator, type: :generator, database: :mysql do
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

    context "when using fx" do
      let(:fx_args) { use_fx_args }

      it "creates migration", :aggregate_failures do
        run_generator(args)

        is_expected.to exist
        is_expected.to contain "ActiveRecord::Migration[#{ar_version}]"
        is_expected.to contain("create_function :logidze_logger, version: 1")
        is_expected.to contain("create_function :logidze_snapshot, version: 1")
        is_expected.to contain("create_function :logidze_version, version: 1")
        is_expected.to contain("create_function :logidze_filter_keys, version: 1")
        is_expected.to contain("create_function :logidze_compact_history, version: 1")

        is_expected.to contain("DROP FUNCTION IF EXISTS logidze_logger")
        is_expected.to contain("DROP FUNCTION IF EXISTS logidze_snapshot")
        is_expected.to contain("DROP FUNCTION IF EXISTS logidze_version")
        is_expected.to contain("DROP FUNCTION IF EXISTS logidze_filter_keys")
        is_expected.to contain("DROP FUNCTION IF EXISTS logidze_compact_history")
      end

      it "creates function files" do
        run_generator(args)

        is_expected.to exist
        %w[
          logidze_logger_v01.sql
          logidze_version_v01.sql
          logidze_filter_keys_v01.sql
          logidze_snapshot_v01.sql
          logidze_compact_history_v01.sql
        ].each do |path|
          expect(file("db/functions/#{path}")).to exist
        end
      end
    end
  end

  context "update migration" do
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
        is_expected.to contain("update_function :logidze_version, version: 1, revert_to_version: 3")
        is_expected.to contain("update_function :logidze_snapshot, version: 1, revert_to_version: 4")
        is_expected.not_to contain("update_function :logidze_filter_keys")
        is_expected.to contain("update_function :logidze_compact_history, version: 1, revert_to_version: 5")
        is_expected.to contain("update_function :logidze_logger, version: 1, revert_to_version: 7")
      end

      it "creates function files" do
        run_generator(args)

        is_expected.to exist
        %w[
          logidze_version_v03.sql
          logidze_snapshot_v4.sql
          logidze_filter_keys_v01.sql
          logidze_compact_history_v05.sql
          logidze_logger_v7.sql
        ].each do |path|
          expect(file("db/functions/#{path}")).to exist
        end
      end
    end
  end
end

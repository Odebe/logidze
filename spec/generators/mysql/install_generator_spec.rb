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
  end
end

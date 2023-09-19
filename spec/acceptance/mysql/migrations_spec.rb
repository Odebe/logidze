# frozen_string_literal: true

require "acceptance_helper"

describe "Logidze migrations", database: :mysql2 do
  describe "#install" do
    let(:check_logidze_command) do
      <<~RUBY.strip
        ActiveRecord::Base
          .connection
          .execute %q{SET @logidze_tmp_json = JSON_OBJECT()};
        
        ActiveRecord::Base
          .connection
          .execute %q{CALL logidze_version(1, JSON_OBJECT(), CURRENT_TIMESTAMP(), @logidze_tmp_json)}
      RUBY
    end

    include_context "cleanup migrations"

    after(:all) do
      Dir.chdir("#{File.dirname(__FILE__)}/../../dummy") do
        successfully "rake db:migrate"
      end
    end

    # Install migration has been already applied at the test suite start
    it "rollbacks" do
      successfully %(
        rails runner "#{check_logidze_command}"
      )

      successfully "rake db:rollback"

      unsuccessfully %(
        rails runner "#{check_logidze_command}"
      )
    end

    xit "creates update migration" do
      successfully "rails generate logidze:install --update"

      successfully "rake db:migrate"

      successfully %(
        rails runner "#{check_logidze_command}"
      )

      successfully "rake db:rollback"
    end
  end

  xdescribe "#model" do
    include_context "cleanup migrations"
    include_context "cleanup models"

    let(:check_logidze_command) { "movie = Movie.create!(title: 'Elm street'); movie.reload.log_version == 1 || raise('Fail')" }

    before do
      successfully "rails generate model Movie title:text"
      successfully "rake db:migrate"
    end

    it "creates migration and patches model" do
      successfully "rails generate logidze:model Movie"

      verify_file_contains "app/models/movie.rb", "has_logidze"

      successfully "rake db:migrate"

      successfully %(
        rails runner "#{check_logidze_command}"
      )

      successfully "rake db:rollback"

      unsuccessfully %(
        rails runner "#{check_logidze_command}"
      )
    end
  end
end

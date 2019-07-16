# frozen_string_literal: true

module Alerts
  class GenerateFindOutMores
    def initialize(school, content_generation_run:)
      @school = school
      @content_generation_run = content_generation_run
    end

    def perform
      @school.alerts.latest.each do |alert|
        FetchContent.new(alert).content_versions(scope: :find_out_more).each do |content_version|
          @content_generation_run.find_out_mores.create!(alert: alert, content_version: content_version)
        end
      end
      @content_generation_run.find_out_mores
    end
  end
end

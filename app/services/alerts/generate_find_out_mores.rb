module Alerts
  class GenerateFindOutMores
    def initialize(school)
      @school = school
    end

    def perform(content_generation_run: nil)
      ActiveRecord::Base.transaction do
        content_generation_run ||= ContentGenerationRun.create!(school: @school)
        @school.alerts.latest.each do |alert|
          process_find_out_mores(alert, content_generation_run)
        end
        content_generation_run.find_out_mores
      end
    end

  private

    def process_find_out_mores(alert, content_generation_run)
      FetchContent.new(alert).content_versions(scope: :find_out_more).each do |content_version|
        content_generation_run.find_out_mores.create!(alert: alert, content_version: content_version)
      end
    end
  end
end

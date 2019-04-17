module Alerts
  class GenerateFindOutMores
    def initialize(school)
      @school = school
    end

    def perform
      ActiveRecord::Base.transaction do
        calculation = FindOutMoreCalculation.create!(school: @school)
        @school.alerts.latest.each do |alert|
          process_find_out_mores(alert, calculation)
        end
      end
    end

  private

    def process_find_out_mores(alert, calculation)
      FetchContent.new(alert).content_versions(find_out_more_active: true).each do |content_version|
        calculation.find_out_mores.create!(alert: alert, content_version: content_version)
      end
    end
  end
end

module Alerts
  class GenerateContent
    def initialize(school)
      @school = school
    end

    def perform
      ActiveRecord::Base.transaction do
        ContentGenerationRun.create!(school: @school).tap do |content_generation_run|
          Alerts::GenerateFindOutMores.new(@school).perform(content_generation_run: content_generation_run)
          Alerts::GenerateDashboardAlerts.new(@school).perform(content_generation_run: content_generation_run)
        end
      end
    end
  end
end

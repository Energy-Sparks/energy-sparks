module Alerts
  class GenerateManagementPriorities
    def initialize(content_generation_run:)
      @content_generation_run = content_generation_run
    end

    def perform(alerts)
      alerts.each do |alert|
        FetchContent.new(alert).content_versions_with_priority(scope: :management_priorities).each do |content_version, priority|
          find_out_more = @content_generation_run.find_out_mores.where(content_version: content_version).first
          @content_generation_run.management_priorities.create!(alert: alert, content_version: content_version, find_out_more: find_out_more, priority: priority)
        end
      end
      @content_generation_run.management_priorities
    end
  end
end

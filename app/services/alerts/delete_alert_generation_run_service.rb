module Alerts
  class DeleteAlertGenerationRunService
    DEFAULT_OLDER_THAN = 3.months.ago.beginning_of_month
    attr_reader :older_than

    def initialize(older_than = DEFAULT_OLDER_THAN)
      @older_than = older_than
    end

    def delete!
      ActiveRecord::Base.transaction do
        alert_generation_runs = AlertGenerationRun.where("created_at <= ?", @older_than)
        alert_generation_runs.destroy_all
      end
    end
  end
end

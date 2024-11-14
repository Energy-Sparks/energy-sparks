module Alerts
  class ContentDeletionService
    DEFAULT_OLDER_THAN = 14.days.ago.to_date
    attr_reader :older_than

    def initialize(older_than = DEFAULT_OLDER_THAN)
      @older_than = older_than
    end

    def delete!
      ActiveRecord::Base.transaction do
        Alerts::DeleteContentGenerationRunService.new(older_than).delete!
        Alerts::DeleteAlertGenerationRunService.new(older_than).delete!
      end
    end
  end
end

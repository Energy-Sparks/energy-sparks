module Alerts
  class DeleteContentGenerationRunService
    DEFAULT_OLDER_THAN = 3.months.ago.beginning_of_month
    attr_reader :older_than

    def initialize(older_than = DEFAULT_OLDER_THAN)
      @older_than = older_than
    end

    def delete!
      ActiveRecord::Base.transaction do
        content_generation_runs = ContentGenerationRun.where("created_at <= ?", @older_than)

        find_out_mores = FindOutMore.where(content_generation_run_id: content_generation_runs)

        find_out_mores.each do |find_out_more|
          # find_out_more.content_version.alert_type_rating.activity_types.delete_all
          # find_out_more.content_version.alert_type_rating.intervention_types.delete_all
          find_out_more.content_version.delete
        end

        content_generation_runs.destroy_all
      end
    end
  end
end

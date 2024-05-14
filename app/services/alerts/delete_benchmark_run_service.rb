module Alerts
  class DeleteBenchmarkRunService
    DEFAULT_OLDER_THAN = 1.month.ago.beginning_of_month
    attr_reader :older_than

    def initialize(older_than = DEFAULT_OLDER_THAN)
      @older_than = older_than
    end

    def delete!
      BenchmarkResultGenerationRun.where('created_at <= ?', @older_than).destroy_all
    end
  end
end

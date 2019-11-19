module Alerts
  class CollateBenchmarkData
    def perform(_asof_date = Time.zone.today)
      School.process_data.each do |school|
        get_benchmarks_for(school)
      end
    end

    private

    def get_benchmarks_for(school)
      _latest_benchmarks = school.latest_benchmarks
    end
  end
end

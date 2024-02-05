require 'dashboard'

module Amr
  class AnalyticsValidatedAmrDataFactory < AnalyticsUnvalidatedAmrDataFactory
    private

    def build_meter_data(active_record_meter)
      validated_reading_array = AmrValidatedReading.where(meter_id: active_record_meter.id).pluck(:reading_date, :status, :substitute_date, :upload_datetime, :kwh_data_x48)
      readings = validated_reading_array.map do |reading|
        OneDayAMRReading.new(
          active_record_meter.mpan_mprn,
          reading[0],
          reading[1],
          reading[2],
          reading[3],
          reading[4].map(&:to_f)
        )
      end
      Amr::AnalyticsMeterFactory.new(active_record_meter).build(readings)
    end
  end
end

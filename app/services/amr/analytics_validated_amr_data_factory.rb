require 'dashboard'

module Amr
  class AnalyticsValidatedAmrDataFactory < AnalyticsUnvalidatedAmrDataFactory
  private

    def build_meter_data(active_record_meter)
      validated_reading_array = AmrValidatedReading.where(meter_id: active_record_meter.id).order(reading_date: :asc).pluck(:reading_date, :status, :substitute_date, :upload_datetime, :kwh_data_x48)
      readings = validated_reading_array.map do |reading|
        {
          reading_date: reading[0],
          type: reading[1],
          substitute_date: reading[2],
          upload_datetime: reading[3],
          kwh_data_x48: reading[4].map(&:to_f)
        }
      end

      Amr::AnalyticsMeterFactory.new(active_record_meter).build(readings)
    end
  end
end

# frozen_string_literal: true

require 'dashboard'

module Amr
  class AnalyticsValidatedAmrDataFactory < AnalyticsUnvalidatedAmrDataFactory
    private

    # override parent method to load validated readings instead
    def load_all_readings
      rows = AmrValidatedReading
             .where(meter_id: all_meter_ids)
             .order(reading_date: :asc)
             .pluck(
               :meter_id,
               :reading_date,
               :status,
               :substitute_date,
               :upload_datetime,
               :kwh_data_x48
             )

      rows.group_by { |meter_id, *_| meter_id }
    end

    def build_meter_data(active_record_meter)
      raw_readings = readings_for_meter(active_record_meter)
      readings = raw_readings.map do |(_, reading_date, status, substitute_date, upload_datetime, kwh_data_x48)|
        OneDayAMRReading.new(
          reading_date,
          status,
          substitute_date,
          upload_datetime,
          kwh_data_x48.map(&:to_f)
        )
      end
      Amr::AnalyticsMeterFactory.new(active_record_meter).build(readings)
    end
  end
end

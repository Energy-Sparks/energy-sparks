module Amr
  class UpsertValidatedReadingsForAMeter
    def initialize(dashboard_meter)
      @dashboard_meter = dashboard_meter
    end

    def perform
      return if AmrDataFeedReading.where(meter_id: @dashboard_meter.external_meter_id).empty?
      p "Processing: #{@dashboard_meter} with mpan_mprn: #{@dashboard_meter.mpan_mprn} id: #{@dashboard_meter.external_meter_id}"
      Upsert.batch(AmrValidatedReading.connection, AmrValidatedReading.table_name) do |upsert|
        amr_data = @dashboard_meter.amr_data
        amr_data.values.each do |one_day_read|
          upsert_from_one_day_reading(@dashboard_meter.external_meter_id, upsert, one_day_read)
        end
      end
    end

  private

    def upsert_from_one_day_reading(meter_id, upsert, one_day_reading)
      upsert.row({ meter_id: meter_id, reading_date: one_day_reading.date },
        meter_id: meter_id,
        reading_date: one_day_reading.date,
        kwh_data_x48: one_day_reading.kwh_data_x48,
        one_day_kwh: one_day_reading.one_day_kwh,
        substitute_date: one_day_reading.substitute_date,
        status: one_day_reading.type,
        upload_datetime: one_day_reading.upload_datetime
      )
    end
  end
end

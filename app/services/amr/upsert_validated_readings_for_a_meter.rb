module Amr
  class UpsertValidatedReadingsForAMeter
    NAN_READINGS = Array.new(48, Float::NAN).freeze

    def initialize(dashboard_meter)
      @dashboard_meter = dashboard_meter
    end

    def perform
      Rails.logger.info "Processing: #{@dashboard_meter} with mpan_mprn: #{@dashboard_meter.mpan_mprn} id: #{@dashboard_meter.external_meter_id}"
      amr_data = @dashboard_meter.amr_data

      validated_amr_data = amr_data.delete_if {|_reading_date, one_day_read| is_nan?(one_day_read) }

      result = AmrValidatedReading.upsert_all(convert_to_hash(validated_amr_data), unique_by: [:meter_id, :reading_date])
      result.rows.flatten.size

      Rails.logger.info "Upserted: #{@dashboard_meter}"
      @dashboard_meter.amr_data = validated_amr_data
      @dashboard_meter
    end

  private

    def convert_to_hash(validated_amr_data)
      validated_amr_data.values.map do |one_day_reading|
      {
        meter_id: @dashboard_meter.external_meter_id,
        reading_date: one_day_reading.date,
        kwh_data_x48: one_day_reading.kwh_data_x48,
        one_day_kwh: one_day_reading.one_day_kwh,
        substitute_date: one_day_reading.substitute_date,
        status: one_day_reading.type,
        upload_datetime: one_day_reading.upload_datetime
      }
      end
    end

    def is_nan?(one_day_reading)
      one_day_reading.one_day_kwh == Float::NAN || one_day_reading.kwh_data_x48 == NAN_READINGS
    end
  end
end

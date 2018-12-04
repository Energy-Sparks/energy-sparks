module Amr
  class UpsertValidatedReadingsForAMeter
    NAN_READINGS = Array.new(48, Float::NAN).freeze

    def initialize(dashboard_meter)
      @dashboard_meter = dashboard_meter
    end

    def perform
      Rails.logger.info "Processing: #{@dashboard_meter} with mpan_mprn: #{@dashboard_meter.mpan_mprn} id: #{@dashboard_meter.external_meter_id}"
      amr_data = @dashboard_meter.amr_data

      Upsert.batch(AmrValidatedReading.connection, AmrValidatedReading.table_name) do |upsert|
        amr_data.values.each do |one_day_read|
          upsert_from_one_day_reading(@dashboard_meter.external_meter_id, upsert, one_day_read)
        end
      end

      dates_to_delete = existing_dates_to_be_deleted(amr_data.keys)
      deleted_count = delete_by_dates(dates_to_delete)
      Rails.logger.info "Processing: #{@dashboard_meter} - deleted: #{deleted_count}"
    end

  private

    def upsert_from_one_day_reading(meter_id, upsert, one_day_reading)
      return if is_nan?(one_day_reading)
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

    def existing_dates_to_be_deleted(new_validated_dates)
      array_of_existing_validated_dates = AmrValidatedReading.where(meter_id: @dashboard_meter.external_meter_id).pluck(:reading_date)
      array_of_existing_validated_dates - new_validated_dates
    end

    def delete_by_dates(dates_to_delete)
      AmrValidatedReading.where(meter_id: @dashboard_meter.external_meter_id, reading_date: dates_to_delete).delete_all
    end

    def is_nan?(one_day_reading)
      one_day_reading.one_day_kwh == Float::NAN || one_day_reading.kwh_data_x48 == NAN_READINGS
    end
  end
end

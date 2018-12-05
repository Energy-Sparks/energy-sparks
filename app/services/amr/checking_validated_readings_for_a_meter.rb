module Amr
  class CheckingValidatedReadingsForAMeter
    NAN_READINGS = Array.new(48, Float::NAN).freeze

    def initialize(dashboard_meter)
      @dashboard_meter = dashboard_meter
    end

    def perform
      pp "Checking: #{@dashboard_meter} with mpan_mprn: #{@dashboard_meter.mpan_mprn} id: #{@dashboard_meter.external_meter_id}"
      amr_data = @dashboard_meter.amr_data
      dates_to_delete = existing_dates_to_be_deleted(amr_data.keys)
      deleted_count = delete_by_dates(dates_to_delete)
      pp "Checked: #{@dashboard_meter} - deleted: #{deleted_count}"
    end

  private

    def existing_dates_to_be_deleted(new_validated_dates)
      array_of_existing_validated_dates = AmrValidatedReading.where(meter_id: @dashboard_meter.external_meter_id).pluck(:reading_date)
      array_of_existing_validated_dates - new_validated_dates
    end

    def delete_by_dates(dates_to_delete)
      AmrValidatedReading.where(meter_id: @dashboard_meter.external_meter_id, reading_date: dates_to_delete).delete_all
    end
  end
end

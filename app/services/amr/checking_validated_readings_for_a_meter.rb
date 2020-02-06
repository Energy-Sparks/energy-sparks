module Amr
  class CheckingValidatedReadingsForAMeter
    NAN_READINGS = Array.new(48, Float::NAN).freeze

    def initialize(dashboard_meter)
      @dashboard_meter = dashboard_meter
    end

    def perform
      pp "Checking: #{@dashboard_meter} with mpan_mprn: #{@dashboard_meter.mpan_mprn} id: #{@dashboard_meter.external_meter_id}"
      amr_data = @dashboard_meter.amr_data

      readings_to_delete = AmrValidatedReading.where(meter_id: @dashboard_meter.external_meter_id).where.not(reading_date: amr_data.keys)
      deleted_count = readings_to_delete.count
      readings_to_delete.delete_all(:delete_all)
      pp "Checked: #{@dashboard_meter} - deleted: #{deleted_count}"
    end
  end
end

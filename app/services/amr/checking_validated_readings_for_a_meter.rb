module Amr
  class CheckingValidatedReadingsForAMeter
    NAN_READINGS = Array.new(48, Float::NAN).freeze

    def initialize(dashboard_meter)
      @dashboard_meter = dashboard_meter
    end

    def perform
      pp "Checking: #{@dashboard_meter} with mpan_mprn: #{@dashboard_meter.mpan_mprn} id: #{@dashboard_meter.external_meter_id}"
      amr_data = @dashboard_meter.amr_data

      # the analytic validation process always returns a full time series of data for each meter.
      # See: ValidateAMR.do_validations which finishes by ensuring all gaps are filled.
      # As there won't be any gaps rather than delete individual days, just remove anything before
      # or after the amr_data start or end date for this meter
      readings_to_delete = AmrValidatedReading.where(meter_id: @dashboard_meter.external_meter_id).where('reading_date < ? OR reading_date > ?', amr_data.start_date, amr_data.end_date)

      # this returns the number of rows affected, so no need for the count
      deleted_count = readings_to_delete.delete_all
      pp "Checked: #{@dashboard_meter} - deleted: #{deleted_count}"
      deleted_count
    end
  end
end

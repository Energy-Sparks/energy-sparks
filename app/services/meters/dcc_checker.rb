# frozen_string_literal: true

module Meters
  class DccChecker
    def initialize(meters)
      @meters = meters
    end

    def perform(to)
      meter_ids = update_meters
      DccMailer.with(meter_ids:).dcc_meter_status_email(to:).deliver_now if meter_ids.any?
    end

    def update_meters
      @meters.filter_map do |meter|
        meter.update!(dcc_checked_at: Time.current, dcc_meter: Meters::N3rgyMeteringService.new(meter).type)
        meter.id if meter.saved_change_to_dcc_meter?
      rescue StandardError => e
        EnergySparks::Log.exception(e, job: :dcc_checker, mpxn: meter.mpan_mprn, school_name: meter.school.name)
      end
    end
  end
end

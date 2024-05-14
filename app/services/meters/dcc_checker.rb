module Meters
  class DccChecker
    def initialize(meters)
      @meters = meters
    end

    def perform
      updated_meters = []
      @meters.each do |meter|
        begin
          fields = { dcc_checked_at: DateTime.now }
          status = Meters::N3rgyMeteringService.new(meter).available?
          fields[:dcc_meter] = status
          meter.update!(fields)
          updated_meters << meter if meter.saved_change_to_dcc_meter?
        rescue => e
          Rails.logger.error("#{e.message} for mpxn #{meter.mpan_mprn}, school #{meter.school.name}")
          Rollbar.error(e, job: :dcc_checker, mpxn: meter.mpan_mprn, school_name: meter.school.name)
        end
      end
      if updated_meters.any?
        DccMailer.with(meter_ids: updated_meters.map(&:id)).dcc_meter_status_email.deliver_now
      end
    end
  end
end

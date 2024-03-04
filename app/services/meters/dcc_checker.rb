module Meters
  class DccChecker
    def initialize(meters, n3rgy_api_factory = Amr::N3rgyApiFactory.new)
      @meters = meters
      @n3rgy_api_factory = n3rgy_api_factory
    end

    def perform
      updated_meters = []
      @meters.each do |meter|
        begin
          fields = { dcc_checked_at: DateTime.now }
          if EnergySparks::FeatureFlags.active?(:n3rgy_v2)
            status = Meters::N3rgyMeteringService.new(meter).available?
          else
            status = @n3rgy_api_factory.data_api(meter).find(meter.mpan_mprn)
          end
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

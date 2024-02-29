module Meters
  class DccWithdrawTrustedConsents
    attr_reader :errors

    def initialize(meters, n3rgy_api_factory = Amr::N3rgyApiFactory.new)
      @meters = meters
      @n3rgy_api_factory = n3rgy_api_factory
      @errors = []
    end

    def perform
      @meters.each do |meter|
        begin
          meter.update(consent_granted: false)
          if EnergySparks::FeatureFlags.active?(:n3rgy_v2)
            DataFeeds::N3rgy::ConsentApiClient.production_client.withdraw_consent(meter.mpan_mprn)
          else
            @n3rgy_api_factory.consent_api(meter).withdraw_trusted_consent(meter.mpan_mprn)
          end
        rescue => e
          @errors << e
          Rails.logger.error("#{e.message} for mpxn #{meter.mpan_mprn}, school #{meter.school.name}")
          Rollbar.error(e, job: :dcc_withdraw_trusted_consents, mpxn: meter.mpan_mprn, school_name: meter.school.name)
        end
      end
      return errors.empty?
    end
  end
end

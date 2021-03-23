module Meters
  class DccChecker
    def initialize(meters, n3rgy_api_factory = Amr::N3rgyApiFactory.new)
      @meters = meters
      @n3rgy_api_factory = n3rgy_api_factory
    end

    def perform
      @meters.each do |meter|
        begin
          fields = { dcc_checked_at: DateTime.now }
          status = @n3rgy_api_factory.data_api(meter).status(meter.mpan_mprn)
          fields[:dcc_meter] = true unless status == :unknown
          meter.update!(fields)
        rescue => e
          Rails.logger.error("#{e.message} for mpxn #{meter.mpan_mprn}, school #{meter.school.name}")
          Rollbar.error(e, job: :dcc_checker, mpxn: meter.mpan_mprn, school_name: meter.school.name)
        end
      end
    end
  end
end

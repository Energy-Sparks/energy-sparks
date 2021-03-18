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
          puts e.inspect
        end
      end
    end
  end
end

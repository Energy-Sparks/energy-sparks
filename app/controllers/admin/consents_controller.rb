module Admin
  class ConsentsController < AdminController
    def index
      meters = Meter.dcc

      @production_consents = production_data_api.list
      @sandbox_consents = sandbox_data_api.list

      @grouped_meters = {}

      meters_by_group = {}
      meters.each do |meter|
        meters_by_group[meter.school.school_group] ||= {}
        meters_by_group[meter.school.school_group][meter.school] ||= []
        meters_by_group[meter.school.school_group][meter.school] << meter
      end

      meters_by_group = meters_by_group.sort_by { |k, _v| k.name }
      meters_by_group.each { |k, v| @grouped_meters[k] = v.sort_by { |x, _y| x.name } }

      mpans = meters.map(&:mpan_mprn).map(&:to_s)
      @orphan_production_consents = @production_consents - mpans
      @orphan_sandbox_consents = @sandbox_consents - mpans

      @total_schools_with_consents = meters.map(&:school).uniq.count
      @total_meters_with_consents = meters.count
    end

    private

    def production_data_api
      @production_data_api ||= MeterReadingsFeeds::N3rgyData.new(api_key: ENV['N3RGY_API_KEY'], base_url: ENV['N3RGY_DATA_URL'])
    end

    def sandbox_data_api
      @sandbox_data_api ||= MeterReadingsFeeds::N3rgyData.new(api_key: ENV['N3RGY_SANDBOX_API_KEY'], base_url: ENV['N3RGY_SANDBOX_DATA_URL'], bad_electricity_standing_charge_units: true)
    end
  end
end

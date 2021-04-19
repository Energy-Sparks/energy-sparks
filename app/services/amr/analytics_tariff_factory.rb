module Amr
  #Convert tariff prices and standing charges into meter attributes for use by analytics
  class AnalyticsTariffFactory
    def initialize(meter)
      @meter = meter
    end

    def build
      return nil unless @meter.dcc_meter?
      convert_to_meter_attributes(build_tariff_data)
    end

    private

    def build_tariff_data
      N3rgyTariffs.new({
        kwh_tariffs: tariffs,
        standing_charges: standing_charges
      }).parameterise
    end

    def convert_to_meter_attributes(tariff_data)
      N3rgyToEnergySparksTariffs.new(tariff_data).convert
    end

    def standing_charges
      Hash[@meter.tariff_standing_charges.by_date.pluck(:start_date, :value)]
    end

    def tariffs
      @meter.tariff_prices.by_date.pluck(:tariff_date, :prices).inject({}) do |result, price|
        result[price[0]] = JSON.parse(price[1])
        result
      end
    end
  end
end

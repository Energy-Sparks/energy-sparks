module Cads
  class RealtimePowerConsumptionService
    DEFAULT_EXPIRY = 45

    def self.cache_power_consumption_service(aggregate_school, cad)
      Rails.cache.fetch(cache_key(cad), expires_in: DEFAULT_EXPIRY.minutes) do
        create_service(aggregate_school, cad)
      end
    end

    def self.read_consumption(cad)
      power_consumption_service = Rails.cache.fetch(cache_key(cad))
      if power_consumption_service
        return power_consumption_service.perform.round(2)
      end
      nil
    end

    private_class_method def self.create_service(aggregate_school, cad)
      meter = find_meter(aggregate_school, cad)
      ::PowerConsumptionService.create_service(aggregate_school, meter)
    end

    private_class_method def self.find_meter(aggregate_school, cad)
      return aggregate_school.aggregated_electricity_meters unless cad.meter.present?
      return aggregate_school.meter?(cad.meter.mpan_mprn.to_s)
    end

    private_class_method def self.cache_key(cad)
      "#{cad.school.id}-#{cad.school.name.parameterize}-power-consumption-service-#{cad.id}"
    end
  end
end

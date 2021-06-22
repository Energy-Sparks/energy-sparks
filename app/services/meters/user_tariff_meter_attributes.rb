module Meters
  class UserTariffMeterAttributes
    def initialize(user_tariff)
      @user_tariff = user_tariff
    end

    def to_meter_attributes
      attrs = {
        "start_date" => @user_tariff.start_date.to_s(:es_compact),
        "end_date" => @user_tariff.end_date.to_s(:es_compact),
        "source" => "manually_entered",
        "name" => @user_tariff.name,
        "type" => "differential",
        "sub_type" => "",
        "vat" => "5%",
      }
      attrs.merge!(rates)
    end

    def rates
      attrs = {}
      @user_tariff.user_tariff_charges.each do |charge|
        attrs[charge.charge_type.to_s] = { "rate" => charge.value.to_s, "per" => charge.units.to_s }
      end
      { "rates" => attrs }
    end
  end
end

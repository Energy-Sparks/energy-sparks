# frozen_string_literal: true

module Solar
  class MeterZUpserter < BaseUpserter
    private

    def meter_model_attributes(details)
      { name: @installation.meter_name(details[:meter_id]) }
    end

    def find_meter_or_create(meter_type, details)
      Meter.find_by!(meter_type:, meter_serial_number: details[:meter_id], meter_z_installation: @installation)
    end
  end
end

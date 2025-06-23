require 'dashboard'

module Solar
  class SolisCloudUpserter < BaseUpserter
    private

    def meter_model_attributes(details)
      { name: @installation.meter_name(details[:serial_number]) }
    end

    def find_meter_or_create(meter_type, details)
      Meter.find_by!(meter_type:, meter_serial_number: details[:serial_number], solis_cloud_installation: @installation)
    end
  end
end

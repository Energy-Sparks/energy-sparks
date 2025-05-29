require 'dashboard'

module Solar
  class SolisCloudUpserter < BaseUpserter
    private

    def meter_model_attributes(details)
      { pseudo: true,
        solis_cloud_installation_id: @installation.id,
        meter_serial_number: details[:serial_number],
        name: "SolisCloud #{details[:name] || details[:serial_number]}" }
    end

    def synthetic_mpan(meter_type, details)
      Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(details[:serial_number].last(12), meter_type)
    end

    def find_meter_or_create(meter_type, details)
      Meter.find_by!(meter_type:, meter_serial_number: details[:serial_number], solis_cloud_installation: @installation)
    end
  end
end

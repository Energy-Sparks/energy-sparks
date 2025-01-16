require 'dashboard'

module Solar
  class SolisCloudUpserter < BaseUpserter
    private

    def meter_model_attributes(details)
      { pseudo: true, solis_cloud_installation: @installation, meter_serial_number: details['id'], active: false }
    end

    def synthetic_mpan(meter_type, details)
      Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(details['sno'].to_i(16), meter_type)
    end
  end
end

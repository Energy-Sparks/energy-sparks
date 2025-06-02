require 'dashboard'

module Solar
  class SolisCloudUpserter < BaseUpserter
    def self.mpan(serial_number)
      Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(serial_number.to_i(16).to_s.last(13), :solar_pv)
    end

    private

    def meter_model_attributes(details)
      {}
    end

    def synthetic_mpan(meter_type, details)
      self.class.mpan(details[:serial_number])
    end

    def find_meter_or_create(meter_type, details)
      Meter.find_by!(meter_type:, meter_serial_number: details[:serial_number], solis_cloud_installation: @installation)
    end
  end
end

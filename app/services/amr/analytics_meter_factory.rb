require 'dashboard'

module Amr
  class AnalyticsMeterFactory
    def initialize(active_record_meter)
      @active_record_meter = active_record_meter
    end

    def build(readings)
      {
        readings:           readings,
        type:               @active_record_meter.meter_type.to_sym,
        identifier:         @active_record_meter.mpan_mprn,
        name:               @active_record_meter.name,
        external_meter_id:  @active_record_meter.id,
        modifiers:          @active_record_meter.meter_attributes
      }
    end
  end
end

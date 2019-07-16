# frozen_string_literal: true

require 'dashboard'

module Amr
  class AnalyticsMeterFactory
    def initialize(active_record_meter, meter_collection, meter_class = Dashboard::Meter)
      @active_record_meter = active_record_meter
      @meter_collection = meter_collection
      @meter_class = meter_class
      @meter_type = @active_record_meter.meter_type.to_sym
    end

    def build
      @meter_class.new(
        meter_collection: @meter_collection,
        amr_data: AMRData.new(@meter_type),
        type: @meter_type,
        identifier: @active_record_meter.mpan_mprn,
        name: @active_record_meter.name,
        external_meter_id: @active_record_meter.id,
        meter_attributes: @active_record_meter.meter_attributes
      )
    end
  end
end

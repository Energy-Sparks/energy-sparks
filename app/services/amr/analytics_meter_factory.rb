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
        dcc_meter:          @active_record_meter.dcc_meter,
        attributes:         all_attributes
      }
    end

    private

    def all_attributes
      attributes = meter_attributes || {}
      tariff_attributes = build_tariff_attributes
      attributes.merge!(tariff_attributes) if tariff_attributes.present?
      return nil if attributes.empty?
      attributes
    end

    def meter_attributes
      @active_record_meter.meter_attributes_to_analytics
    end

    def build_tariff_attributes
      Amr::AnalyticsTariffFactory.new(@active_record_meter).build
    end
  end
end

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

      return nil if attributes.empty? && tariff_attributes.nil?
      return attributes if tariff_attributes.nil?

      if attributes.key?(:accounting_tariff_generic)
        attributes[:accounting_tariff_generic] += tariff_attributes[:accounting_tariff_generic]
      else
        attributes[:accounting_tariff_generic] = tariff_attributes
      end

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

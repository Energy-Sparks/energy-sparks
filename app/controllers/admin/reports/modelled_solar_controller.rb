# frozen_string_literal: true

module Admin
  module Reports
    class ModelledSolarController < BaseSolarMeterController
      private

      def title = 'Modelled Solar'

      def columns = super.insert(-2, kwp_column)

      def kwp_column = Column.new('kWp', ->(meter) { meter.solar_attribute_data['kwp'] })

      def query = Report::SolarMeter.modelled
    end
  end
end

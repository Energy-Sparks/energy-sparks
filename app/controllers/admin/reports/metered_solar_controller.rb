# frozen_string_literal: true

module Admin
  module Reports
    class MeteredSolarController < BaseSolarMeterController
      private

      def title = 'Metered Solar'

      def columns
        super.insert(-2,
                     real_generation_meters_column,
                     export_column,
                     BoolColumn.new(:modelled_solar_pv_generation, :has_modelled_solar_pv_generation_attribute),
                     BoolColumn.new(:modelled_solar, :has_solar_pv_attribute),
                     BoolColumn.new(:solar_override, :has_solar_pv_override_attribute))
      end

      def real_generation_meters_column
        Column.new(:real_generation_meters,
                   lambda { |meter|
                     meter.solar_pv_mapping_data.count do |key, value|
                       key.start_with?('production_') && value.present?
                     end
                   })
      end

      def export_column
        BoolColumn.new(:export, ->(meter) { meter.solar_pv_mapping_data['export_mpan'].present? })
      end

      def query = Report::SolarMeter.metered
    end
  end
end

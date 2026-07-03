# frozen_string_literal: true

module Admin
  module Reports
    class MeteredSolarController < BaseImportReportsController
      private

      def columns
        column_names = %i[school_group admin school meter data_source supplier meter_status]
        columns = super.filter { |column| column_names.include?(column.name) }
        columns.insert(4, BoolColumn.new(:active))
        columns + [
          real_generation_meters_column,
          BoolColumn.new(:modelled_solar_pv_generation?, :has_modelled_solar_pv_generation_attribute),
          BoolColumn.new(:modelled_solar?, :has_solar_pv_attribute),
          BoolColumn.new(:solar_overrides?, :has_solar_pv_override_attribute),
          action_column
        ]
      end

      def real_generation_meters_column
        Column.new(:real_generation_meters,
                   lambda { |meter|
                     meter.solar_pv_mapping_data.count do |key, value|
                       key.start_with?('production_') && value.present?
                     end
                   })
      end

      def action_column
        Column.new('', nil,
                   ->(meter) { link_to('Attributes', admin_school_single_meter_attribute_path(meter.school, meter)) },
                   display: :html, html_data: { sortable: false })
      end

      def results = filter_results(Report::Table::MeteredSolarTable.query)

      def filter_results(results)
        filtered = super
        filtered = filtered.where(school: School.find(params.expect(:school))) if params[:school].present?
        filtered
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  module Reports
    class MeteredSolarController < BaseImportReportsController
      private

      def title = 'Metered Solar'

      def columns
        column_names = %i[school_group admin school meter data_source supplier admin_meter_status]
        columns = super.filter { |column| column_names.include?(column.name) }
        columns.insert(column_names.index(:meter) + 1, BoolColumn.new(:active))
        columns + [date_column(:start_date),
                   date_column(:end_date),
                   real_generation_meters_column,
                   BoolColumn.new(:modelled_solar_pv_generation, :has_modelled_solar_pv_generation_attribute),
                   BoolColumn.new(:modelled_solar, :has_solar_pv_attribute),
                   BoolColumn.new(:solar_overrides, :has_solar_pv_override_attribute),
                   export_column,
                   action_column]
      end

      def date_column(type) = Column.new(type, ->(meter) { date_parse(meter.solar_pv_mapping_data[type.to_s]) })

      def date_parse(date) = date.present? ? Date.parse(date) : nil

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

      def action_column
        Column.new('', nil,
                   lambda { |meter|
                     link_to('Attributes', admin_school_single_meter_attribute_path(meter.school, meter),
                             class: 'btn btn-sm btn-secondary')
                   },
                   display: :html, html_data: { sortable: false })
      end

      def results
        filtered = filter_results(Report::MeteredSolar.query)
        filtered = filtered.where(school: School.find(params.expect(:school))) if params[:school].present?
        filtered
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  module Reports
    class BaseSolarMeterController < BaseImportReportsController
      private

      def columns
        column_names = %i[school_group admin school meter data_source supplier admin_meter_status]
        columns = super.filter { |column| column_names.include?(column.name) }
        columns.insert(column_names.index(:meter) + 1, BoolColumn.new(:active))
        columns + [date_column(:start_date),
                   date_column(:end_date),
                   action_column]
      end

      def date_column(type) = Column.new(type, ->(meter) { date_parse(meter.solar_attribute_data[type.to_s]) })

      def date_parse(date) = date.present? ? Date.parse(date) : nil

      def action_column
        Column.new('', nil,
                   lambda { |meter|
                     link_to('Attributes', admin_school_single_meter_attribute_path(meter.school, meter),
                             class: 'btn btn-sm btn-secondary')
                   },
                   display: :html, html_data: { sortable: false })
      end

      def results
        filtered = filter_results(query)
        filtered = filtered.where(school: School.find(params.expect(:school))) if params[:school].present?
        filtered
      end
    end
  end
end

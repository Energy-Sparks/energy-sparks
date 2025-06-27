# frozen_string_literal: true

module Admin
  module Reports
    class MeterDataReportsController < AdminController
      include Columns
      include ActionView::Helpers::UrlHelper
      include ApplicationHelper
      before_action :set_metadata
      before_action :set_columns

      def index
        @results = results
        respond_to do |format|
          format.html
          format.csv do
            send_data(csv_report(@columns, @results),
                      filename: EnergySparks::Filenames.csv(controller_name))
          end
        end
      end

      private

      def set_metadata
        @title = title
        @description = description
        @frequency = frequency
        @path = path
      end

      def title; end
      def description; end
      def path; end

      def frequency
        :daily
      end

      def set_columns
        @columns = columns
      end

      def columns
        [
          Column.new(:school_group,
                     ->(row) { row.meter.school&.school_group&.name },
                     ->(row, csv) { csv && link_to(csv, school_group_path(row.meter.school&.school_group)) }),
          Column.new(:admin,
                     ->(row) { row.meter.school&.school_group&.default_issues_admin_user&.name }),
          Column.new(:school,
                     ->(row) { row.meter.school.name },
                     ->(row, csv) { link_to(csv, school_path(row.meter.school)) }),
          Column.new(:meter,
                     ->(row) { row.meter.mpan_mprn },
                     ->(row, csv) { link_to(csv, school_meter_path(row.meter.school, row.meter)) }),
          Column.new(:meter_name,
                     ->(row) { row.meter&.name })
        ]
      end

      def set_breadcrumbs
        @breadcrumbs = [
          { name: 'Admin', href: admin_path },
          { name: 'Reports', href: admin_reports_path },
          { name: title }
        ]
      end
    end
  end
end

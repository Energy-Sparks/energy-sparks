# frozen_string_literal: true

# Base class for admin reports that present meter or reading level data
# Provides a basic framework for implementing the reports and some standard
# columns
module Admin
  module Reports
    class BaseMeterReportsController < AdminController
      include Columns
      include ActionView::Helpers::UrlHelper
      include ApplicationHelper
      before_action :set_metadata

      layout 'admin_reports'

      def index
        @results = results
        respond_to do |format|
          format.html do
            @columns = columns.filter(&:display_html)
          end
          format.csv do
            send_data(csv_report(@columns, @results),
                      filename: EnergySparks::Filenames.csv(controller_name))
          end
        end
      end

      private

      def set_metadata
        @container = container_class
        @title = title
        @description = description
        @frequency = frequency
        @columns = columns
      end

      # Report title
      def title; end
      # Single line description of report
      # Add a _help.html.erb partial to add more detail
      def description; end

      # How frequently are the reports contents updated?
      def frequency
        :on_demand
      end

      # Override to be 'container-fluid' for very wide reports
      def container_class
        'container'
      end

      # Standard set of columns for the results table, assumes each row is a Meter
      # Override to add additional columns for the report
      def columns
        [
          Column.new(:school_group,
                     ->(meter) { meter.school&.school_group&.name },
                     ->(meter, csv) { csv && link_to(csv, school_group_path(meter.school&.school_group)) }),
          Column.new(:admin,
                     ->(meter) { meter.school&.school_group&.default_issues_admin_user&.name }),
          Column.new(:school,
                     ->(meter) { meter.school.name },
                     ->(meter, csv) { link_to(csv, school_path(meter.school)) }),
          Column.new(:meter,
                     ->(meter) { meter.mpan_mprn },
                     ->(meter, csv) { link_to(csv, school_meter_path(meter.school, meter)) }),
          Column.new(:meter_name,
                     ->(meter) { meter&.name })
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

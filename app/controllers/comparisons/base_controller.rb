# frozen_string_literal: true

module Comparisons
  class BaseController < ApplicationController
    include UserTypeSpecific
    skip_before_action :authenticate_user!

    before_action :filter
    before_action :set_schools
    helper_method :index_params
    before_action :set_advice_page
    before_action :set_report
    before_action :set_headers

    def index
      @results = load_data
      respond_to do |format|
        format.html do
          @charts = create_charts(@results)
          @table_names = table_names
        end
        format.csv do
          filename = "#{key}-#{filter[:table_name]}-#{Time.zone.now.iso8601}.csv"
          response.headers['Content-Type'] = 'text/csv'
          response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
          render partial: filter[:table_name].to_s
        end
      end
    end

    private

    def colgroups
      []
    end

    def headers
      []
    end

    def set_headers
      @colgroups = colgroups
      @headers = headers
    end

    def set_report
      @report = Comparison::Report.find_by_key(key) if key
    end

    def set_advice_page
      @advice_page = AdvicePage.find_by_key(advice_page_key) if advice_page_key
      @advice_page_tab = advice_page_tab
    end

    # Key for the Comparison::Report
    def key
      nil
    end

    # Key for the AdvicePage used to link to school analysis
    def advice_page_key
      nil
    end

    # Tab of the advice page to link to by default
    def advice_page_tab
      :insights
    end

    # Load the results from the view
    def load_data
      nil
    end

    # Create the chart configuration used to display chart
    def create_charts(_results)
      []
    end

    # Returns a list of table names. These correspond to a partial that should be
    # found in the views folder for the comparison. By default assumes a single table
    # which is defined in a file called _table.html.erb.
    #
    # Partials will be provided with the report, advice page, and results
    def table_names
      [:table]
    end

    def create_single_number_chart(results, name, multiplier, series_name, y_axis_label)
      chart_data = {}

      # Some charts also set x_max_value to 100 if there are metric values > 100
      # Removes issues with schools with large % changes breaking the charts
      #
      # This could be done by clipping values to 100.0 if the metric has a
      # unit of percentage/relative_percent
      results.each do |result|
        metric = result.send(name)
        next if metric.nil? || metric.nan? || metric.infinite?

        # for a percentage metric we'd multiply * 100.0
        # for converting from kW to W 1000.0
        metric *= multiplier unless multiplier.nil?
        chart_data[result.school.name] = metric
      end

      [{
        id: :comparison,
        x_axis: chart_data.keys,
        x_data: { I18n.t("analytics.benchmarking.configuration.column_headings.#{series_name}") => chart_data.values },
        y_axis_label: I18n.t("chart_configuration.y_axis_label_name.#{y_axis_label}")
      }]
    end

    def create_multi_chart(results, names, multiplier, y_axis_label)
      chart_data = {}
      schools = []

      results.each do |result|
        schools << result.school.name
        result.slice(*names.keys).each do |metric, value|
          value ||= 0
          # for a percentage metric we'd multiply * 100.0
          # for converting from kW to W 1000.0
          value *= multiplier unless multiplier.nil?
          (chart_data[metric] ||= []) << value
        end
      end

      chart_data.transform_keys! { |key| I18n.t("analytics.benchmarking.configuration.column_headings.#{names[key.to_sym]}") }

      [{
        id: :comparison,
        x_axis: schools,
        x_data: chart_data, # x is the vertical axis by default for stacked charts in Highcharts
        y_axis_label: I18n.t("chart_configuration.y_axis_label_name.#{y_axis_label}")
      }]
    end

    def filter
      @filter ||=
        params.permit(:search, :benchmark, :country, :school_type, :funder, school_group_ids: [], school_types: [])
          .with_defaults(school_group_ids: [], school_types: School.school_types.keys, table_name: table_names.first)
          .to_hash.symbolize_keys
    end

    def index_params
      filter.merge(anchor: filter[:search])
    end

    def set_schools
      @schools = included_schools
    end

    def included_schools
      include_invisible = can? :show, :all_schools
      school_params = filter.slice(:school_group_ids, :school_types, :school_type, :country, :funder).merge(include_invisible: include_invisible)

      filter = SchoolFilter.new(**school_params).filter
      filter = filter.accessible_by(current_ability, :show) unless include_invisible
      filter.pluck(:id)
    end
  end
end

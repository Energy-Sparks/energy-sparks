# frozen_string_literal: true

module Comparisons
  class BaseController < ApplicationController
    include UserTypeSpecific
    skip_before_action :authenticate_user!

    before_action :filter
    before_action :set_schools
    before_action :set_advice_page
    before_action :set_report
    before_action :set_results, only: [:index]
    before_action :set_unlisted_schools_count, only: [:index]
    before_action :set_headers, only: [:index]

    helper_method :index_params
    helper_method :footnote_cache
    helper_method :unlisted_message

    protect_from_forgery except: :unlisted

    def index
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
        format.json do
          render json: create_chart_json
        end
      end
    end

    def unlisted
      @unlisted = School.where(id: (@schools - load_data.pluck(:school_id))).order(:name)
      respond_to(&:js)
    end

    # Used to store footnotes loaded by the comparison table component across multiple calls in one page
    def footnote_cache
      @footnote_cache ||= {}
    end

    private

    def header_groups
      []
    end

    def colgroups(groups: nil)
      (groups || header_groups).each { |group| group[:colspan] = group[:headers].count(&:itself) }
    end

    def headers(groups: nil)
      (groups || header_groups).pluck(:headers).flatten.select(&:itself)
    end

    def set_headers
      @colgroups = colgroups
      @headers = headers
    end

    def set_report
      @report = Comparison::Report.find_by!(key: key) if key
    end

    def set_results
      @results = load_data
    end

    def set_unlisted_schools_count
      @unlisted_schools_count = @schools.length - @results.length
    end

    def set_advice_page
      @advice_page = AdvicePage.find_by!(key: advice_page_key) if advice_page_key
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

    # Returns a list of table names. These correspond to a partial that should be
    # found in the views folder for the comparison. By default assumes a single table
    # which is defined in a file called _table.html.erb.
    #
    # Partials will be provided with the report, advice page, and results
    def table_names
      [:table]
    end

    def create_charts(_results)
      []
    end

    def create_chart(results, metric_to_translation_key, multiplier, y_axis_label,
                     column_heading_keys: 'analytics.benchmarking.configuration.column_headings',
                     y_axis_keys: 'chart_configuration.y_axis_label_name')
      chart_data = {}
      schools = []

      results.each do |result|
        schools << result.school.name
        result.slice(*metric_to_translation_key.keys).each do |metric, value|
          next if value.nil? || (value.respond_to?(:nan?) && (value.nan? || value.infinite?))

          # for a percentage metric we'd multiply * 100.0
          # for converting from kW to W 1000.0
          value *= multiplier unless multiplier.nil?
          (chart_data[metric] ||= []) << value
        end
      end

      chart_data.transform_keys! { |key| I18n.t("#{column_heading_keys}.#{metric_to_translation_key[key.to_sym]}") }

      { id: :comparison,
        x_axis: schools,
        x_data: chart_data, # x is the vertical axis by default for stacked charts in Highcharts
        y_axis_label: I18n.t("#{y_axis_keys}.#{y_axis_label}") }
    end

    def create_single_number_chart(results, name, multiplier, series_name, y_axis_label, **kwargs)
      [create_chart(results, { name => series_name }, multiplier, y_axis_label, **kwargs)]
    end

    def create_multi_chart(results, names, multiplier, y_axis_label, **kwargs)
      [create_chart(results, names, multiplier, y_axis_label, **kwargs)]
    end

    def create_chart_json
      chart_data = create_charts(@results).first
      return {} unless chart_data.is_a?(Hash)
      chart_data = chart_data.except(:id).merge({ chart1_type: :bar, chart1_subtype: :stacked })
      ChartDataValues.as_chart_json(ChartDataValues.new(chart_data, :comparison).process)
    end

    def filter
      @filter ||= params.permit(:search, :benchmark, :country, :school_type, :funder, :table_name,
                                school_group_ids: [], school_types: [])
                        .with_defaults(school_group_ids: [], school_types: School.school_types.keys)
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
      school_params = filter.slice(:school_group_ids, :school_types, :school_type, :country,
                                   :funder).merge(include_invisible: include_invisible)

      filter = SchoolFilter.new(**school_params).filter
      filter = filter.accessible_by(current_ability, :show) unless include_invisible
      filter.pluck(:id)
    end

    def unlisted_message(count)
      I18n.t('comparisons.unlisted.message', count: count)
    end
  end
end

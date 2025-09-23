# frozen_string_literal: true

module Comparisons
  class BaseController < ApplicationController
    include UserTypeSpecific
    include ComparisonTableGenerator
    include SchoolGroupBreadcrumbs
    include SchoolGroupAdvice
    include SchoolGroupAccessControl

    skip_before_action :authenticate_user!

    before_action :filter
    before_action :set_schools
    before_action :set_advice_page
    before_action :set_report
    before_action :set_results, only: [:index]
    before_action :set_unlisted_schools_count, only: [:index]
    before_action :set_headers, only: [:index]
    before_action :set_school_group_vars, only: [:index]

    protect_from_forgery except: :unlisted

    layout :switch_layout

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

    private

    # Key for the Comparison::Report
    def key
      nil
    end

    # Load the results from the view
    def load_data
      nil
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

      chart_hash(schools, chart_data, y_axis_label, y_axis_keys:)
    end

    def create_single_number_chart(results, name, multiplier, series_name, y_axis_label, **kwargs)
      [create_chart(results, { name => series_name }, multiplier, y_axis_label, **kwargs)]
    end

    def create_calculated_chart(results, lambda, series_name, y_axis_label, column_heading_keys: 'analytics.benchmarking.configuration.column_headings', y_axis_keys: 'chart_configuration.y_axis_label_name')
      chart_data = {}
      schools = []

      results.each do |result|
        schools << result.school.name
        value = lambda.call(result)
        next if value.nil? || (value.respond_to?(:nan?) && (value.nan? || value.infinite?))
        (chart_data[I18n.t("#{column_heading_keys}.#{series_name}")] ||= []) << value
      end

      chart_hash(schools, chart_data, y_axis_label, y_axis_keys:)
    end

    def create_multi_chart(results, names, multiplier, y_axis_label, **kwargs)
      [create_chart(results, names, multiplier, y_axis_label, **kwargs)]
    end

    def chart_hash(schools, chart_data, y_axis_label, y_axis_keys: 'chart_configuration.y_axis_label_name')
      { id: :comparison,
        x_axis: schools,
        x_data: chart_data, # x is the vertical axis by default for stacked charts in Highcharts
        y_axis_label: I18n.t("#{y_axis_keys}.#{y_axis_label}") }
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

    def switch_layout
      params[:group] == 'true' ? 'dashboards' : 'application'
    end

    def set_school_group_vars
      @school_group_layout = params[:group] == 'true'
      return unless @school_group_layout
      @school_group = SchoolGroup.find(params[:school_group_ids].reject(&:blank?).first)
      set_all_group_advice_vars
      redirect_unless_authorised and return
      build_breadcrumbs([
                          { name: I18n.t('advice_pages.breadcrumbs.root'), href: school_group_advice_path(@school_group) },
                          { name: I18n.t('school_groups.titles.comparisons'), href: comparison_reports_school_group_advice_path(@school_group) },
                          { name: @report.title }
                        ])
    end
  end
end

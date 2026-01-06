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
    before_action :set_school_group, only: [:index]
    before_action :redirect_unless_authorised, only: [:index]
    before_action :set_advice_vars_and_breadcrumbs, only: [:index]

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
                     y_axis_keys: 'chart_configuration.y_axis_label_name', **kwargs)
      Charts::ComparisonChartData.new(results,
                                      column_heading_keys:,
                                      y_axis_keys:,
                                      x_min_value: kwargs[:x_min_value],
                                      x_max_value: kwargs[:x_max_value],
                                      fuel_type: @report.fuel_type).create_chart(
                                        metric_to_translation_key, multiplier, y_axis_label
      )
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
      ChartDataValues.as_chart_json(ChartDataValues.new(chart_data, :comparison, fuel_type: @report.fuel_type).process)
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

    def set_school_group
      @school_group_layout = params[:group] == 'true'
      @school_group = SchoolGroup.find(params[:school_group_ids].reject(&:blank?).first) if @school_group_layout
    end

    def redirect_unless_authorised
      return unless @school_group_layout
      super
    end

    def set_advice_vars_and_breadcrumbs
      return unless @school_group_layout
      load_schools
      set_fuel_types
      set_counts
      build_breadcrumbs([
                          { name: I18n.t('advice_pages.breadcrumbs.root'), href: school_group_advice_path(@school_group) },
                          { name: I18n.t('school_groups.titles.comparisons'), href: comparison_reports_school_group_advice_path(@school_group) },
                          { name: @report.title }
                        ])
    end
  end
end

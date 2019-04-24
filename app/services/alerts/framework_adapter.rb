require 'dashboard'

module Alerts
  class FrameworkAdapter
    class Report
      attr_reader :status, :detail, :summary, :help_url, :rating, :template_data, :chart_data, :table_data
      def initialize(status:, detail:, summary:, help_url:, rating:, template_data: {}, chart_data: {}, table_data: {})
        @status = status
        @detail = detail
        @summary = summary
        @help_url = help_url
        @rating = rating
        @template_data = template_data
        @chart_data = chart_data
        @table_data = table_data
      end
    end

    class Adapter
      def initialize(alert_type:, school:, analysis_date:, aggregate_school:)
        @alert_type = alert_type
        @school = school
        @analysis_date = analysis_date
        @aggregate_school = aggregate_school
      end

      def alert_class
        @alert_type.class_name.constantize
      end
    end

    class AnalyticsAdapter < Adapter
      def report
        analysis_obj = alert_class.new(@aggregate_school)
        analysis_obj.analyse(@analysis_date)

        analysis_report = analysis_obj.analysis_report
        summary = analysis_report.summary || "There was a problem running the #{@alert_type.title} alert. This is likely due to missing data."
        pull_template_data = !(analysis_report.status == :failed) && @alert_type.has_variables?

        Report.new(
          status:   analysis_report.status,
          summary:  summary,
          detail:   analysis_report.detail,
          help_url: analysis_report.help_url,
          rating:   analysis_report.rating,
          template_data: pull_template_data ? analysis_obj.front_end_template_data : {},
          chart_data:    pull_template_data ? analysis_obj.front_end_template_charts : {},
          table_data:    pull_template_data ? analysis_obj.front_end_template_tables : {}
        )
      end
    end

    def initialize(alert_type, school, analysis_date = nil, aggregate_school = AggregateSchoolService.new(school).aggregate_school)
      @alert_type = alert_type
      @school = school
      @aggregate_school = aggregate_school
      @analysis_date = analysis_date || calculate_analysis_date
    end

    def analyse
      report = AnalyticsAdapter.new(alert_type: @alert_type, school: @school, analysis_date: @analysis_date, aggregate_school: @aggregate_school).report
      build_alert(report)
    end

  private

    def calculate_analysis_date
      return Time.zone.today if @alert_type.fuel_type.nil?
      @aggregate_school.analysis_date(@alert_type.fuel_type)
    end

    def build_alert(analysis_report)
      Alert.new(
        school_id:      @school.id,
        alert_type_id:  @alert_type.id,
        run_on:         @analysis_date,
        status:         analysis_report.status,
        summary:        analysis_report.summary,
        data:           data_hash(analysis_report)
      )
    end

    def data_hash(analysis_report)
      {
        help_url:      analysis_report.help_url,
        detail:        analysis_report.detail,
        rating:        analysis_report.rating,
        template_data: analysis_report.template_data,
        chart_data:    analysis_report.chart_data,
        table_data:    analysis_report.table_data
      }
    end
  end
end

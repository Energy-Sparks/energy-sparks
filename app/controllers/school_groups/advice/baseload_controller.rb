module SchoolGroups
  module Advice
    class BaseloadController < BaseController
      include ComparisonTableGenerator
      include SchoolGroupAccessControl
      include SchoolGroupBreadcrumbs

      load_resource :school_group

      # FIXME
      def insights
        categorised_schools = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_schools
        @baseload_comparison = categorised_schools[:electricity][:baseload]

        @baseload_per_pupil_report = Comparison::Report.find_by!(key: :baseload_per_pupil)
        @results = load_data
        @insight_table_headers = insight_table_headers
      end

      # FIXME
      def analysis
        categorised_schools = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_schools
        @baseload_comparison = categorised_schools[:electricity][:baseload]

        @baseload_per_pupil_report = Comparison::Report.find_by!(key: :baseload_per_pupil)
        @results = load_data
        @baseload_per_pupil_headers = Comparison::BaseloadPerPupil.report_headers
      end

      private

      def insight_table_headers
        [
          I18n.t('analytics.benchmarking.configuration.column_headings.school'),
          I18n.t('analytics.benchmarking.configuration.column_headings.baseload_per_pupil_w'),
          I18n.t('analytics.benchmarking.configuration.column_headings.average_baseload_kw'),
        ]
      end

      def advice_page_key
        :baseload
      end

      def index_params
        { benchmark: :baseload_per_pupil, school_group_ids: [@school_group.id] }
      end

      def load_data
        Comparison::BaseloadPerPupil.for_schools(@schools).where.not(one_year_baseload_per_pupil_kw: nil).order(one_year_baseload_per_pupil_kw: :desc)
      end
    end
  end
end

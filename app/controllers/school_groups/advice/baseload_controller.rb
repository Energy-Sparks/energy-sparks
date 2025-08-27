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
      end

      def analysis
        @baseload_per_pupil_report = Comparison::Report.find_by!(key: :baseload_per_pupil)
        @results = load_data
        @baseload_per_pupil_headers = Comparison::BaseloadPerPupil.report_headers
      end

      private

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

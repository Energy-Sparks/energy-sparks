module SchoolGroups
  module Advice
    class BaseAdviceWithComparisonController < BaseController
      include ComparisonTableGenerator

      before_action :run_report

      private

      def run_report
        @report = Comparison::Report.find_by!(key: report_key)
        @results = load_data
      end

      def index_params
        { benchmark: report_key, school_group_ids: [@school_group.id] }
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  module Reports
    class LaggingMetersController < BaseImportReportsController
      private

      def results
        filter_results(ImportNotifier.new.meters_running_behind)
      end

      def description
        'List of meters that have stale data'
      end

      def title
        'Meters with stale data'
      end
    end
  end
end

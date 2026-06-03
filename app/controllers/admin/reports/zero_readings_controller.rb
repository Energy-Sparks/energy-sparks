# frozen_string_literal: true

module Admin
  module Reports
    class ZeroReadingsController < BaseImportReportsController
      private

      def results
        filter_results(ImportNotifier.new.meters_with_zero_data)
      end

      def description
        'Meters where we have received one or more days of entirely zero readings in the last 24 hours'
      end

      def title
        'Meters with recent zero readings'
      end
    end
  end
end

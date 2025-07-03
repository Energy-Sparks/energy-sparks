# frozen_string_literal: true

module Admin
  module Reports
    class BlankReadingsController < BaseImportReportsController
      private

      def results
        filter_results(ImportNotifier.new.meters_with_blank_data)
      end

      def description
        'Meters where we have received one or more days of entirely blank data in the last 24 hours'
      end

      def title
        'Meters with recent blank readings'
      end
    end
  end
end

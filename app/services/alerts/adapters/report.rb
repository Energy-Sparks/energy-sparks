# frozen_string_literal: true

module Alerts
  module Adapters
    class Report
      attr_reader :valid, :status, :rating, :enough_data, :template_data, :chart_data, :table_data
      def initialize(valid:, status:, rating:, enough_data:, template_data: {}, chart_data: {}, table_data: {})
        @valid = valid
        @status = status
        @rating = rating
        @enough_data = enough_data
        @template_data = template_data
        @chart_data = chart_data
        @table_data = table_data
      end

      def displayable?
        valid &&
          !status.nil? &&
          !(status == :failed) &&
          !enough_data.nil? &&
          !(enough_data == :not_enough) &&
          !rating.nil?
      end
    end
  end
end

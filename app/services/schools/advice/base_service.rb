module Schools
  module Advice
    class BaseService
      def initialize(school, meter_collection)
        @school = school
        @meter_collection = meter_collection
      end

      # from analytics: lib/dashboard/charting_and_reports/content_base.rb
      # helper method that returns a rating out of 10, based on mapping
      # the provided value into an expected good/bad range.
      def calculate_rating_from_range(good_value, bad_value, actual_value)
        actual_value = actual_value.abs
        [10.0 * [(actual_value - bad_value) / (good_value - bad_value), 0.0].max, 10.0].min.round(1)
      end

      private

      def meter_for_mpan(mpan_mprn)
        @school.meters.find_by(mpan_mprn: mpan_mprn)
      end
    end
  end
end

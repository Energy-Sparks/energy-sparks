module Admin
  module Reports
    class SchoolScenariosController < AdminController
      helper_method :with_limited_data, :with_fuel_types

      def index
        @limit = params[:limit].present? ? params[:limit].to_i : 5
        @schools = School.data_visible.with_config
      end

      private

      def with_fuel_types(electricity: true, gas: true)
        @schools.filter_map do |school|
          next unless school.has_electricity? == electricity &&
                      school.has_gas? == gas
          school
        end
      end

      def with_limited_data(fuel_type: :electricity, min_days_of_data: 0, max_days_of_data: 365, recent_data: true, scenario: :less_than_x_days)
        @schools.filter_map do |school|
          dates = ::Schools::AnalysisDates.new(school, fuel_type)
          next unless school.send("has_#{fuel_type}?")

          case scenario
          when :less_than_x_days
            next unless dates.days_of_data >= min_days_of_data &&
                        dates.days_of_data <= max_days_of_data &&
                        dates.recent_data == recent_data
          when :between_1_and_2_years
            next unless dates.days_of_data > 365 && dates.days_of_data <= 730 && dates.recent_data == recent_data
          when :more_than_2_years
            next unless dates.days_of_data > 730 && dates.recent_data == recent_data
          when :not_recent
            next unless dates.recent_data == false
          else
            next
          end

          [school, dates]
        end
      end
    end
  end
end

# frozen_string_literal: true

module Charts
  module MergeMonthlyComparisons
    # monthly comparison charts e.g. electricity_cost_comparison_last_2_years_accounting
    # can be awkward as some years may occasionally have subtely different numbers of months e.g. 12 v. 13
    # so specific month date matching occurs to match one year with the next
    def self.merge(results, number_of_periods)
      x_axis = calculate_x_axis(results)
      bucketed_data = {}
      bucketed_data_count = {}
      results.each do |result|
        time_description = number_of_periods <= 1 ? '' : result.xbucketor.compact_date_range_description

        # This series will have either the same number or fewer months than the other range
        #
        # If we have same number of months then we're comparing, e.g. two full year (52*7) week periods
        # So the columns are already aligned.
        #
        # If we have fewer months than the full range then we need to copy into a new array with the
        # monthly values in the right position.
        #
        # When we have fewer months then the months will correspond with the months at the final part of the
        # full range. So use the last occurence of the month name when finding the right index.
        if x_axis.length == result.x_axis.length
          data = result.bucketed_data.values[0]
          count_data = result.bucketed_data_count.values[0]
        else
          data = Array.new(x_axis.length, 0.0)
          count_data = Array.new(x_axis.length, 0)
          sub_array_index = find_sub_array_index(x_axis, remove_years(result.x_axis))
          if sub_array_index.nil?
            Rollbar.error('error in comparison chart merge', x_axis:, result_x_axis: remove_years(result.x_axis))
            raise RuntimeError('error in comparison chart merge')
          else
            end_index = sub_array_index + result.x_axis.length
            data[sub_array_index...end_index] = result.bucketed_data.values[0]
            count_data[sub_array_index...end_index] = result.bucketed_data_count.values[0]
          end
        end
        bucketed_data[time_description] = data
        bucketed_data_count[time_description] = count_data
      end
      { x_axis:, bucketed_data:, bucketed_data_count: }
    end

    private_class_method def self.calculate_x_axis(results)
      axis_months = results.map { |result| remove_years(result.x_axis) }
      axis_months.reverse!
      x_axis, *axis_months = axis_months
      axis_months.each do |months|
        if (x_axis - months).empty?
          x_axis = months
        else
          index = x_axis.find_index(months.first) || x_axis.length
          x_axis[index..index + months.length] = months
        end
      end
      x_axis
    end

    private_class_method def self.remove_years(month_years)
      month_years.map { |month_year| month_year[0..2] }
    end

    private_class_method def self.find_sub_array_index(array, sub_array)
      array.each_cons(sub_array.size).with_index { |cons, index| return index if cons == sub_array }
      nil
    end
  end
end

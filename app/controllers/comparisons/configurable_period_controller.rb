# frozen_string_literal: true

module Comparisons
  class ConfigurablePeriodController < Shared::ArbitraryPeriodController
    private

    def key
      params[:key]
    end

    def load_data
      Comparison::ConfigurablePeriod.for_schools(@schools)
                                    .where(custom_period_id: @report.custom_period.id)
                                    .with_data_for_previous_period
                                    .by_total_percentage_change
    end

    def table_names
      [:total] # , :electricity, :gas, :storage_heater]
    end

    # def create_charts(results)
    #   # change as appropriate!
    #   create_single_number_chart(results, name, multiplier, series_name, y_axis_label)
    # end
  end
end

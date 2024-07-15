# frozen_string_literal: true

module Comparisons
  class ConfigurablePeriodController < Shared::ArbitraryPeriodController
    private

    def key
      params[:key]
    end

    def load_data
      Comparison::ConfigurablePeriod.for_schools(@schools)
                                    .where(comparison_report_id: @report.id)
                                    .with_data_for_previous_period
                                    .by_total_percentage_change
    end
  end
end

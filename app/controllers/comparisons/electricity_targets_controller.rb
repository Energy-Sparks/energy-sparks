module Comparisons
  class ElectricityTargetsController < BaseController
    private

    def key
      :electricity_targets
    end

    def advice_page_key
      :your_advice_page_key
    end

    def load_data
      Comparison::ElectricityTargets.where(school: @schools).where.not(variable_name: nil).order(variable_name: :desc)
    end

    def create_charts(results)
      chart_data = {}

      puts chart_data.inspect
      puts results.inspect
    end
  end
end

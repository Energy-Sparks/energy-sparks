module Comparisons
  class SolarGenerationSummaryController < BaseController
    private

    def key
      :solar_generation_summary
    end

    def advice_page_key
      :solar_pv
    end

    def load_data
      Comparison::SolarGenerationSummary.where(school: @schools).with_data.sort_default
    end
  end
end

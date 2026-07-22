# frozen_string_literal: true

module Comparisons
  class SolarGenerationSummaryController < BaseController
    private

    def headers
      Comparison::SolarGenerationSummary.report_headers
    end

    def key
      :solar_generation_summary
    end

    def advice_page_key
      :solar_pv
    end

    def load_data
      Comparison::SolarGenerationSummary.for_schools(@schools).with_data.sort_default
    end

    def create_charts(results)
      create_multi_chart(results, {
                           annual_mains_consumed_kwh: :solar_mains_consume,
                           annual_solar_pv_consumed_onsite_kwh: :solar_self_consume
                         }, 1.0, :kwh)
    end
  end
end

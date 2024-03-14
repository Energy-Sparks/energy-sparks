# frozen_string_literal: true

module Comparisons
  class AnnualChangeInElectricityOutOfHoursUseController < BaseController
    include AnnualChangeInOutOfHoursUse

    private

    def key
      :annual_change_in_electricity_out_of_hours_use
    end

    def advice_page_key
      :electricity_out_of_hours
    end

    def model
      Comparison::AnnualChangeInElectricityOutOfHoursUse
    end
  end
end

# frozen_string_literal: true

module Comparisons
  class AnnualChangeInGasOutOfHoursUseController < Shared::AnnualChangeInOutOfHoursUse
    private

    def key
      :annual_change_in_gas_out_of_hours_use
    end

    def advice_page_key
      :gas_out_of_hours
    end

    def model
      Comparison::AnnualChangeInGasOutOfHoursUse
    end
  end
end

module Comparisons
  class AnnualChangeInStorageHeaterOutOfHoursUseController < Shared::AnnualChangeInOutOfHoursUse
    private

    def key
      :annual_change_in_storage_heater_out_of_hours_use
    end

    def advice_page_key
      :storage_heaters
    end

    def model
      Comparison::AnnualChangeInStorageHeaterOutOfHoursUse
    end
  end
end

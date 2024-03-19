module Comparisons
  class ChangeInStorageHeatersSinceLastYearController < BaseController
    include ChangeInHeatingSinceLastYear

    private

    def key
      :change_in_storage_heaters_since_last_year
    end

    def model
      Comparison::ChangeInStorageHeatersSinceLastYear
    end
  end
end

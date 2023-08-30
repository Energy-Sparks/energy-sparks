module Admin
  module Reports
    class EnergyTariffsController < AdminController
      def index
        @count_by_school_group = EnergyTariff.count_by_school_group
      end
    end
  end
end

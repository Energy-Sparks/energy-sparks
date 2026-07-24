module Admin
  module Reports
    class DataLoadsController < AdminController
      include Pagy::Method
      def index
        @all_data_loads = ManualDataLoadRun.by_date
        @pagy, @data_loads = pagy(@all_data_loads, items: 20)
      end
    end
  end
end

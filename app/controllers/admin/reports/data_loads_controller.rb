module Admin
  module Reports
    class DataLoadsController < AdminController
      def index
        @data_loads = ManualDataLoadRun.by_date.limit(50)
      end
    end
  end
end

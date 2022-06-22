module Admin
  module Reports
    class TransifexLoadsController < AdminController
      def index
        @transifex_loads = TransifexLoad.by_date.limit(50)
      end

      def show
        @transifex_load = TransifexLoad.find(params[:id])
      end
    end
  end
end

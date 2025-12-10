module Admin
  module Reports
    class AmrReadingWarningsController < AdminController
      include Pagy::Method

      def index
        @pagy_warnings, @warnings = pagy(AmrReadingWarning.order(created_at: :desc))
        @maximum_rows_before_pagination = Pagy::DEFAULT[:items]
      end
    end
  end
end

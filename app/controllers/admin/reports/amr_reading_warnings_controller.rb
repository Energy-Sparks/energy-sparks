module Admin
  module Reports
    class AmrReadingWarningsController < AdminController
      include Pagy::Backend

      def index
        @pagy_warnings, @warnings = pagy(AmrReadingWarning.order(created_at: :desc))
        @maximum_rows_before_pagination = Pagy::VARS[:items]
      end
    end
  end
end

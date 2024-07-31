module Admin
  module Reports
    class SolarPanelsController < AdminController
      def index
        @metered_solar = MeterAttribute.metered_solar
        @estimated_solar = MeterAttribute.solar_pv
      end
    end
  end
end

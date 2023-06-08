module Admin
  module Reports
    class SolarPanelsController < AdminController
      def index
        @solar_panels = MeterAttribute.solar_panels
      end
    end
  end
end

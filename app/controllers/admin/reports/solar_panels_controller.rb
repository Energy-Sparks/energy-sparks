module Admin
  module Reports
    class SolarPanelsController < AdminController
      def index
        @solar_panels = MeterAttribute.solar_panels
        @number_of_schools = @solar_panels.uniq(&:school_id).count
      end
    end
  end
end

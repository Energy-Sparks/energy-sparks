module Admin
  module Reports
    class TariffsController < AdminController
      def index
        school_meters = Meter.where(dcc_meter: true).group_by(&:school)
        @group_meters = school_meters.group_by { |school, _meters| school.area_name }
      end

      def show
        @meter = Meter.find(params[:meter_id])
      end
    end
  end
end

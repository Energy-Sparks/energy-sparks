module Admin
  module Reports
    class TariffsController < AdminController
      def index
        school_meters = Meter.where(dcc_meter: true, consent_granted: true, sandbox: false).group_by(&:school)
        @group_meters = school_meters.group_by { |school, _meters| school.area_name }
      end

      def show
        @meter = Meter.find(params[:meter_id])
        @school = @meter.school
      end
    end
  end
end

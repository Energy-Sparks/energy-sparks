module Admin
  module Schools
    class SingleMeterAttributesController < AdminController
      before_action :set_view_paths
      load_and_authorize_resource :school

      include MeterAttributesHelper

      def show
        @available_meter_attributes = MeterAttributes.all
        @meter = @school.meters.find(params[:id])
      end

      private

      def set_view_paths
        prepend_view_path 'app/views/admin/schools/meter_attributes'
      end
    end
  end
end

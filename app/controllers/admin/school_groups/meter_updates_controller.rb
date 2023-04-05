module Admin
  module SchoolGroups
    class MeterUpdatesController < AdminController
      load_and_authorize_resource :school_group

      def index
      end

      def bulk_update_meters
        meters = @school_group.meters.where(meter_type: meter_types)
        meters.update_all(data_source_id: meter_update_params[:data_source_id])
        redirect_to(admin_school_group_path(@school_group), notice: "Meters successfully updated for #{meters.count} for all #{meter_types.to_sentence} meters for this school group.") and return
      end

      private

      def meter_types
        @meter_types ||= meter_update_params['meter_update_id'] == 'solar_pv' ? %w(solar_pv exported_solar_pv) : [meter_update_params['meter_update_id']]
      end

      def meter_update_params
        params.permit(:data_source_id, :meter_update_id)
      end
    end
  end
end

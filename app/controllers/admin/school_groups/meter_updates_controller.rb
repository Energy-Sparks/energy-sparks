module Admin
  module SchoolGroups
    class MeterUpdatesController < AdminController
      load_and_authorize_resource :school_group

      def index
      end

      def bulk_update_meter_data_source
        meters = @school_group.meters.where(meter_type: meter_types)
        if meters.update_all(data_source_id: meter_update_params['data_source_id']&.to_i)
          notice = "Data source for #{meters.count} #{meter_types.to_sentence} #{'meter'.pluralize(meters.count)} successfully updated for this school group."
          redirect_to(admin_school_group_meter_updates_path(@school_group), notice: notice) and return
        else
          render :index, status: :unprocessable_entity
        end
      end

      def bulk_update_meter_procurement_route
        meters = @school_group.meters.where(meter_type: meter_types)
        if meters.update_all(procurement_route_id: meter_update_params['procurement_route_id']&.to_i)
          notice = "Procurement route for #{meters.count} #{meter_types.to_sentence} #{'meter'.pluralize(meters.count)} successfully updated for this school group."
          redirect_to(admin_school_group_meter_updates_path(@school_group), notice: notice) and return
        else
          render :index, status: :unprocessable_entity
        end
      end

      private

      def meter_types
        @meter_types ||= params['meter_update_id'] == 'solar_pv' ? %w(solar_pv exported_solar_pv) : [params['meter_update_id']]
      end

      def meter_update_params
        params.require(:meter).permit(:data_source_id, :procurement_route_id)
      end
    end
  end
end

# frozen_string_literal: true

module Admin
  module SchoolGroups
    class MeterUpdatesController < AdminController
      load_and_authorize_resource :school_group

      def index; end

      def bulk_update_meter_data_source
        bulk_update('data_source')
      end

      def bulk_update_meter_procurement_route
        bulk_update('procurement_route')
      end

      private

      def bulk_update(field)
        # binding.pry
        meters = @school_group.meters.where(meter_type: meter_types)
        if meters.update_all("#{field}_id": meter_update_params["#{field}_id"]&.to_i)
          @school_group.update(
            "default_#{field}_#{params[:meter_update_fuel_type]}_id": meter_update_params["#{field}_id"]&.to_i
          )
          # binding.pry
          redirect_to(admin_school_group_meter_updates_path(@school_group),
                      notice: "#{field.titleize} for #{meters.count} #{meter_types.to_sentence} " \
                              "#{'meter'.pluralize(meters.count)} successfully updated for this school group.")
        else
          render :index, status: :unprocessable_entity
        end
      end

      def meter_types
        meter_types = [params[:meter_update_fuel_type]]
        meter_types << 'exported_solar_pv' if meter_types.first == 'solar_pv'
        meter_types
      end

      def meter_update_params
        # permit
        params[params[:meter_update_fuel_type]].permit(:data_source_id, :procurement_route_id)
      end
    end
  end
end

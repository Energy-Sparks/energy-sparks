# frozen_string_literal: true

module Admin
  module SchoolGroups
    class MeterUpdatesController < AdminController
      include SchoolGroupBreadcrumbs

      load_and_authorize_resource :school_group

      before_action :breadcrumbs

      layout 'group_settings'

      def index; end

      def bulk_update_meter_data_source
        bulk_update('data_source')
      end

      def bulk_update_meter_procurement_route
        bulk_update('procurement_route')
      end

      def bulk_update_meter_supplier
        bulk_update('supplier', group_field: nil)
      end

      def bulk_update_meter_admin_meter_status
        bulk_update('admin_meter_status', meter_field: 'admin_meter_statuses_id',
                                          group_field: "admin_meter_statuses_#{params[:meter_update_fuel_type]}_id")
      end

      private

      def bulk_update(field, meter_field: "#{field}_id",
                      group_field: "default_#{field}_#{params[:meter_update_fuel_type]}_id")
        meters = @school_group.meters.where(meter_type: meter_types)
        value = meter_update_params[meter_field]&.to_i
        count = meters.update_all(meter_field => value)
        @school_group.update(group_field => value) if group_field
        redirect_to(admin_school_group_meter_updates_path(@school_group),
                    notice: "#{field.titleize} for #{count} #{meter_types.to_sentence} " \
                            "#{'meter'.pluralize(meters.count)} successfully updated for this school group.")
      end

      def meter_types
        meter_types = [params[:meter_update_fuel_type]]
        meter_types << 'exported_solar_pv' if meter_types.first == 'solar_pv'
        meter_types
      end

      def meter_update_params
        params.permit(electricity: {}, gas: {}, solar_pv: {})[params[:meter_update_fuel_type]]
              .permit(:data_source_id, :procurement_route_id, :supplier_id, :admin_meter_statuses_id)
      end

      def breadcrumbs
        build_breadcrumbs([{ name: t('school_groups.titles.meter_updates') }])
      end
    end
  end
end

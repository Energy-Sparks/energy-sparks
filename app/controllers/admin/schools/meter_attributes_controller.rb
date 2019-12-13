module Admin
  module Schools
    class MeterAttributesController < ApplicationController
      load_and_authorize_resource :school

      def index
        @available_meter_attributes = MeterAttributes.all
        @meters = @school.meters.order(:mpan_mprn)
      end

      def new
        @meter_attribute_type = MeterAttributes.all[params[:type].to_sym]
      end

      def create
        meter = @school.meters.find(params[:attribute][:meter_id])
        meter.meter_attributes.create!(
          attribute_type: params[:attribute][:type],
          reason: params[:attribute][:reason],
          input_data: params[:attribute][:root],
          created_by: current_user
        )
        redirect_to admin_school_meter_attributes_path(@school)
      end

      def show
        @meter_attribute = MeterAttribute.find(params[:id])
      end

      def edit
        @meter_attribute = MeterAttribute.find(params[:id])
        @meter_attribute_type = @meter_attribute.meter_attribute_type
        @input_data = @meter_attribute.input_data
      end

      def update
        meter_attribute = MeterAttribute.find(params[:id])
        new_attribute = meter_attribute.meter.meter_attributes.create!(
          attribute_type: meter_attribute.attribute_type,
          reason: params[:attribute][:reason],
          input_data: params[:attribute][:root],
          created_by: current_user
        )
        meter_attribute.update!(replaced_by: new_attribute)
        redirect_to admin_school_meter_attributes_path(@school)
      end

      def destroy
        meter_attribute = MeterAttribute.find(params[:id])
        meter_attribute.update!(deleted_by: current_user)
        redirect_to admin_school_meter_attributes_path(@school)
      end
    end
  end
end

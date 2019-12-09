module Schools
  module Meters
    class MeterAttributesController < ApplicationController
      load_and_authorize_resource :school
      load_and_authorize_resource :meter, through: :school


      def new
        authorize! :create, MeterAttribute
        @meter_attribute_type = MeterAttributes.all[params[:type].to_sym]
      end

      def create
        authorize! :create, MeterAttribute
        @meter.meter_attributes.create!(
          attribute_type: params[:attribute][:type],
          reason: params[:attribute][:reason],
          input_data: params[:attribute][:root],
          created_by: current_user
        )
        redirect_to school_meter_path(@school, @meter)
      end

      def show
        @meter_attribute = @meter.meter_attributes.find(params[:id])
        authorize! :edit, @meter_attribute
      end

      def edit
        @meter_attribute = @meter.meter_attributes.find(params[:id])
        @meter_attribute_type = @meter_attribute.meter_attribute_type
        authorize! :edit, @meter_attribute
        @input_data = @meter_attribute.input_data
      end

      def update
        meter_attribute = @meter.meter_attributes.find(params[:id])
        authorize! :edit, meter_attribute
        new_attribute = @meter.meter_attributes.create!(
          attribute_type: meter_attribute.attribute_type,
          reason: params[:attribute][:reason],
          input_data: params[:attribute][:root],
          created_by: current_user
        )
        meter_attribute.update!(replaced_by: new_attribute)
        redirect_to school_meter_path(@school, @meter)
      end

      def destroy
        meter_attribute = @meter.meter_attributes.find(params[:id])
        authorize! :delete, meter_attribute
        meter_attribute.update!(deleted_by: current_user)
        redirect_to school_meter_path(@school, @meter)
      end
    end
  end
end

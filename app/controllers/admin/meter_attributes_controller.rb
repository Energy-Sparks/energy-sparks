module Admin
  class MeterAttributesController < ApplicationController
    load_and_authorize_resource :school_group

    def index
      @meter_attributes = @school_group.meter_attributes
      @available_meter_attributes = MeterAttributes.all
    end

    def new
      @meter_attribute_type = MeterAttributes.all[params[:type].to_sym]
    end

    def create
      @school_group.meter_attributes.create!(
        attribute_type: params[:attribute][:type],
        reason: params[:attribute][:reason],
        input_data: params[:attribute][:root],
        meter_type: params[:attribute][:meter_type]
      )
      redirect_to admin_school_group_meter_attributes_path(@school_group)
    end

    def edit
      @meter_attribute = @school_group.meter_attributes.find(params[:id])
      @meter_attribute_type = @meter_attribute.meter_attribute_type
      authorize! :edit, @meter_attribute
      @input_data = @meter_attribute.input_data
    end

    def update
      @meter_attribute = @school_group.meter_attributes.find(params[:id])
      @meter_attribute_type = @meter_attribute.meter_attribute_type
      authorize! :edit, @meter_attribute
      @input_data = params[:attribute][:root]
      if @meter_attribute.update(
        input_data: @input_data,
        reason: params[:attribute][:reason],
        meter_type: params[:attribute][:meter_type]
      )
        redirect_to admin_school_group_meter_attributes_path(@school_group)
      else
        render :edit
      end
    end

    def destroy
      @meter_attribute = @school_group.meter_attributes.find(params[:id])
      authorize! :delete, @meter_attribute
      @meter_attribute.destroy
      redirect_to admin_school_group_meter_attributes_path(@school_group)
    end
  end
end

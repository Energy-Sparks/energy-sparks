module Schools
  class MeterAttributesController < ApplicationController
    load_and_authorize_resource :school

    def index
      @meter_attributes = @school.meter_attributes
      @available_meter_attributes = MeterAttributes.all
    end

    def new
      @meter_attribute_type = MeterAttributes.all[params[:type].to_sym]
    end

    def create
      @school.meter_attributes.create!(
        attribute_type: params[:attribute][:type],
        reason: params[:attribute][:reason],
        input_data: params[:attribute][:root],
        meter_type: params[:attribute][:meter_type]
      )
      redirect_to school_meter_attributes_path(@school)
    end

    def edit
      @meter_attribute = @school.meter_attributes.find(params[:id])
      @meter_attribute_type = @meter_attribute.meter_attribute_type
      authorize! :edit, @meter_attribute
      @input_data = @meter_attribute.input_data
    end

    def update
      @meter_attribute = @school.meter_attributes.find(params[:id])
      @meter_attribute_type = @meter_attribute.meter_attribute_type
      authorize! :edit, @meter_attribute
      @input_data = params[:attribute][:root]
      if @meter_attribute.update(
        input_data: @input_data,
        reason: params[:attribute][:reason],
        meter_type: params[:attribute][:meter_type]
      )
        redirect_to school_meter_attributes_path(@school)
      else
        render :edit
      end
    end

    def destroy
      @meter_attribute = @school.meter_attributes.find(params[:id])
      authorize! :delete, @meter_attribute
      @meter_attribute.destroy
      redirect_to school_meter_attributes_path(@school)
    end
  end
end

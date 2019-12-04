module Schools
  class MeterAttributesController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :meter, through: :school


    def new
      @meter_attribute_type = MeterAttributes.all[params[:type].to_sym]
    end

    def create
      @meter.meter_attributes.create!(attribute_type: params[:attribute][:type], reason: params[:attribute][:reason], input_data: params[:attribute][:root])
      redirect_to school_meter_path(@school, @meter)
    end

    def edit
      @meter_attribute = @meter.meter_attributes.find(params[:id])
      authorize! :edit, @meter_attribute
      @input_data = @meter_attribute.input_data
    end

    def update
      @meter_attribute = @meter.meter_attributes.find(params[:id])
      authorize! :edit, @attribute
      @input_data = params[:attribute][:root]
      if @meter_attribute.update(input_data: @input_data, reason: params[:attribute][:reason])
        redirect_to school_meter_path(@school, @meter)
      else
        render :edit
      end
    end

    def destroy
      @meter_attribute = @meter.meter_attributes.find(params[:id])
      authorize! :delete, @attribute
      @meter_attribute.destroy
      redirect_to school_meter_path(@school, @meter)
    end
  end
end

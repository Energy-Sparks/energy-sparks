module Admin
  class GlobalMeterAttributesController < AdminController
    load_and_authorize_resource :school_group

    def index
      @meter_attributes = GlobalMeterAttribute.active
      @deleted_meter_attributes = GlobalMeterAttribute.deleted
      @available_meter_attributes = MeterAttributes.all
    end

    def new
      @meter_attribute_type = MeterAttributes.all[params[:type].to_sym]
    end

    def create
      GlobalMeterAttribute.create!(
        attribute_type: params[:attribute][:type],
        reason: params[:attribute][:reason],
        input_data: params[:attribute][:root],
        meter_type: params[:attribute][:meter_type],
        created_by: current_user
      )
      redirect_to admin_global_meter_attributes_path
    end

    def show
      @meter_attribute = GlobalMeterAttribute.find(params[:id])
      authorize! :show, @meter_attribute
    end

    def edit
      @meter_attribute = GlobalMeterAttribute.find(params[:id])
      @meter_attribute_type = @meter_attribute.meter_attribute_type
      authorize! :edit, @meter_attribute
      @input_data = @meter_attribute.input_data
    end

    def update
      meter_attribute = GlobalMeterAttribute.find(params[:id])
      authorize! :edit, @meter_attribute
      new_attribute = GlobalMeterAttribute.create!(
        attribute_type: meter_attribute.attribute_type,
        reason: params[:attribute][:reason],
        input_data: params[:attribute][:root],
        meter_type: params[:attribute][:meter_type],
        created_by: current_user
      )
      meter_attribute.update!(replaced_by: new_attribute)
      redirect_to admin_global_meter_attributes_path
    end

    def destroy
      meter_attribute = GlobalMeterAttribute.find(params[:id])
      authorize! :delete, meter_attribute
      meter_attribute.update!(deleted_by: current_user)
      redirect_to admin_global_meter_attributes_path
    end
  end
end

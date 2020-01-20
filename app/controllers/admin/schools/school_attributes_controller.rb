module Admin
  module Schools
    class SchoolAttributesController < AdminController
      load_and_authorize_resource :school

      def index
        @meter_attributes = @school.meter_attributes.active
        @deleted_meter_attributes = @school.meter_attributes.deleted
        @group_meter_attributes = @school.school_group.meter_attributes.active
        @global_meter_attributes = GlobalMeterAttribute.active
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
          meter_types: params[:attribute][:meter_types],
          created_by: current_user
        )
        redirect_to admin_school_school_attributes_path(@school)
      end

      def show
        @meter_attribute = @school.meter_attributes.find(params[:id])
      end

      def edit
        @meter_attribute = @school.meter_attributes.find(params[:id])
        @meter_attribute_type = @meter_attribute.meter_attribute_type
        authorize! :edit, @meter_attribute
        @input_data = @meter_attribute.input_data
      end

      def update
        meter_attribute = @school.meter_attributes.find(params[:id])
        new_attribute = @school.meter_attributes.create!(
          attribute_type: meter_attribute.attribute_type,
          reason: params[:attribute][:reason],
          input_data: params[:attribute][:root],
          meter_types: params[:attribute][:meter_types],
          created_by: current_user
        )
        meter_attribute.update!(replaced_by: new_attribute)
        redirect_to admin_school_school_attributes_path(@school)
      end

      def destroy
        meter_attribute = @school.meter_attributes.find(params[:id])
        meter_attribute.update!(deleted_by: current_user)
        redirect_to admin_school_school_attributes_path(@school)
      end
    end
  end
end

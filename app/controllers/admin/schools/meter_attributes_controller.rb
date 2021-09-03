module Admin
  module Schools
    class MeterAttributesController < AdminController
      load_and_authorize_resource :school

      include MeterAttributesHelper

      def index
        @available_meter_attributes = MeterAttributes.all
        @meters = @school.meters.order(:mpan_mprn)
      end

      def new
        @meter_attribute_type = MeterAttributes.all[params[:type].to_sym]
      end

      def create
        service = Meters::MeterAttributeManager.new(@school)
        service.create!(
          params[:attribute][:meter_id],
          params[:attribute][:type],
          params[:attribute][:root],
          params[:attribute][:reason],
          current_user
        )
        redirect_to admin_school_meter_attributes_path(@school)
      rescue => e
        redirect_back fallback_location: admin_school_meter_attributes_path(@school), notice: e.message
      end

      def show
        @meter_attribute = MeterAttribute.find(params[:id])
      end

      def edit
        @meter_attribute = MeterAttribute.find(params[:id])
        @meter_attribute.validate!
        @meter_attribute_type = @meter_attribute.meter_attribute_type
        @input_data = @meter_attribute.input_data
      rescue => e
        redirect_back fallback_location: admin_school_meter_attributes_path(@school), notice: e.message
      end

      def update
        service = Meters::MeterAttributeManager.new(@school)
        service.update!(
          params[:id],
          params[:attribute][:root],
          params[:attribute][:reason],
          current_user
        )
        redirect_to admin_school_meter_attributes_path(@school)
      rescue => e
        redirect_back fallback_location: edit_admin_school_meter_attribute_path(@school, meter_attribute), notice: e.message
      end

      def destroy
        service = Meters::MeterAttributeManager.new(@school)
        service.delete!(params[:id], current_user)
        redirect_to admin_school_meter_attributes_path(@school)
      rescue => e
        redirect_back fallback_location: admin_school_meter_attributes_path(@school), notice: e.message
      end
    end
  end
end

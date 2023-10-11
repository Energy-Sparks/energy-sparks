module Admin
  class MeterAttributesController < AdminController
    def index
      attributes = School.all.order(:name).each_with_object({}) do |school, collection|
        meter_attributes = school.meters.each_with_object({}) do |meter, meters|
          analytics_attributes = meter.meter_attributes_to_analytics
          meters[meter.mpan_mprn] = analytics_attributes unless analytics_attributes.empty?
        end
        collection[school.urn] = {
          name: school.name,
          meter_attributes: meter_attributes,
          pseudo_meter_attributes: school.pseudo_meter_attributes_to_analytics
        }
      end
      respond_to do |format|
        format.yaml { send_data YAML.dump(attributes), filename: 'meter_attributes.yml' }
      end
    end
  end
end

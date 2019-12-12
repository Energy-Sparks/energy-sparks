module Admin
  class MeterAttributesController < AdminController
    def index
      attributes = School.all.order(:name).inject({}) do |collection, school|
        meter_attributes = school.meters.inject({}) do |meters, meter|
          analytics_attributes = meter.meter_attributes_to_analytics
          meters[meter.mpan_mprn] = analytics_attributes unless analytics_attributes.empty?
          meters
        end
        collection[school.urn] = {
          name: school.name,
          meter_attributes: meter_attributes,
          pseudo_meter_attributes: school.pseudo_meter_attributes_to_analytics
        }
        collection
      end
      respond_to do |format|
        format.yaml { send_data YAML.dump(attributes), filename: "meter_attributes.yml" }
      end
    end
  end
end

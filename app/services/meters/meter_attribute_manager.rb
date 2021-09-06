module Meters
  class MeterAttributeManager
    include Wisper::Publisher

    def initialize(school)
      @school = school
      subscribe(Targets::FuelTypeEventListener.new)
    end

    def create!(meter_id, attribute_type, input_data, reason, user)
      meter = @school.meters.find(meter_id)
      attribute = meter.meter_attributes.create!(
        attribute_type: attribute_type,
        reason: reason,
        input_data: input_data,
        created_by: user
      )
      broadcast(:meter_attribute_created, attribute)
      attribute
    end

    def update!(attribute_id, input_data, reason, user)
      attribute = MeterAttribute.find(attribute_id)
      new_attribute = attribute.meter.meter_attributes.create!(
        attribute_type: attribute.attribute_type,
        reason: reason,
        input_data: input_data,
        created_by: user
      )
      attribute.update!(replaced_by: new_attribute)
      broadcast(:meter_attribute_updated, attribute)
      attribute
    end

    def delete!(attribute_id, user)
      attribute = MeterAttribute.find(attribute_id)
      attribute.deleted_by = user
      attribute.save(validate: false)
      broadcast(:meter_attribute_deleted, attribute)
      attribute
    end
  end
end

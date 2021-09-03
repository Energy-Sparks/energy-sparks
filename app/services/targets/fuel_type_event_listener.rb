module Targets
  class FuelTypeEventListener
    def meter_attribute_created(attribute)
      school_target = school_target(attribute)
      return unless school_target.present?
      if storage_heater_attribute?(attribute) &&
         storage_heater_attribute_count(attribute) == 1
         school_target.suggest_revision = true
         school_target.revised_fuel_types |= ["storage heater"]
         school_target.save
      end
    end

    private

    def storage_heater_attribute?(attribute)
      attribute.attribute_type == "storage_heaters"
    end

    def school_target(attribute)
      attribute.meter.school.most_recent_target
    end

    def storage_heater_attribute_count(attribute)
      school = attribute.meter.school
      count = 0
      school.meters.each do |meter|
        count += meter.meter_attributes.where(attribute_type: "storage_heaters").count
      end
      count
    end
  end
end

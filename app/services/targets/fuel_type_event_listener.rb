module Targets
  class FuelTypeEventListener
    # From Meter Attribute Manager
    def meter_attribute_created(attribute)
      target = school_target(attribute.meter)
      return if target.blank?

      if storage_heater_attribute?(attribute) && first_storage_heater_attribute?(attribute)
        add_fuel_type(target, 'storage_heater')
      end
    end

    def meter_attribute_deleted(attribute)
      target = school_target(attribute.meter)
      return if target.blank?

      if storage_heater_attribute?(attribute) && last_storage_heater_attribute?(attribute)
        remove_fuel_type(target, 'storage_heater')
      end
    end

    # From Meter Management
    def meter_activated(meter)
      target = school_target(meter)
      return if target.blank?

      add_fuel_type(target, meter.meter_type) if gas_or_electricity?(meter) && first_activated_meter_of_type?(meter)
    end

    # From Meter Management
    def meter_deactivated(meter)
      target = school_target(meter)
      return if target.blank?

      remove_fuel_type(target, meter.meter_type) if gas_or_electricity?(meter) && last_activated_meter_of_type?(meter)
    end

    private

    def add_fuel_type(target, fuel_type)
      target.revised_fuel_types |= [fuel_type]
      target.save
    end

    def remove_fuel_type(target, fuel_type)
      target.revised_fuel_types.delete(fuel_type)
      target.save
    end

    def school_target(meter)
      meter.school.most_recent_target
    end

    def storage_heater_attribute?(attribute)
      attribute.attribute_type == 'storage_heaters'
    end

    def gas_or_electricity?(meter)
      Meter::MAIN_METER_TYPES.include?(meter.fuel_type)
    end

    def first_activated_meter_of_type?(meter)
      active_meter_count(meter.school, meter.meter_type) == 1
    end

    def last_activated_meter_of_type?(meter)
      active_meter_count(meter.school, meter.meter_type) == 0
    end

    def active_meter_count(school, meter_type)
      school.meters.active.where(meter_type: meter_type).count
    end

    def first_storage_heater_attribute?(attribute)
      active_storage_heater_attribute_count(attribute) == 1
    end

    def last_storage_heater_attribute?(attribute)
      active_storage_heater_attribute_count(attribute) == 0
    end

    def active_storage_heater_attribute_count(attribute)
      school = attribute.meter.school
      count = 0
      school.meters.each do |meter|
        count += meter.meter_attributes.where(attribute_type: 'storage_heaters', deleted_by: nil).count
      end
      count
    end
  end
end

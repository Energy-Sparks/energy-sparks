module TargetsHelper
  def show_limited_data?(school_target, fuel_type)
    EnergySparks::FeatureFlags.active?(:school_targets_v2) && school_target[fuel_type].present?
  end

  def estimated_usage_for(school, fuel_type)
    return nil unless school.configuration.estimated_consumption_for_fuel_type(fuel_type).present?
    FormatEnergyUnit.format(:kwh, school.configuration.estimated_consumption_for_fuel_type(fuel_type), :html, false, true, :target)
  end
end

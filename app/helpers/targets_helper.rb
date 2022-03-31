module TargetsHelper
  def show_limited_data?(school_target, fuel_type)
    EnergySparks::FeatureFlags.active?(:school_targets_v2) && school_target[fuel_type].present?
  end

  def estimated_usage_for(school, fuel_type)
    return nil unless school.configuration.estimated_consumption_for_fuel_type(fuel_type).present?
    FormatEnergyUnit.format(:kwh, school.configuration.estimated_consumption_for_fuel_type(fuel_type), :html, false, true, :target)
  end

  def link_to_progress_report?(school_target, fuel_type)
    meter_start_date = school_target.school.configuration.meter_start_date(fuel_type)
    return false if meter_start_date.nil?
    return meter_start_date <= school_target.start_date
  end
end

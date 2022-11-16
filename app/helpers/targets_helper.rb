module TargetsHelper
  def reportable_progress?(progress_summary)
    progress_summary.present? && progress_summary.current_target?
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

  def estimate_to_low?(school, value, fuel_type)
    estimate = school.configuration.estimated_consumption_for_fuel_type(fuel_type)
    return '' unless estimate.present? && value.present?
    value < estimate ? 'text-danger' : ''
  end
end

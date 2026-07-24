# frozen_string_literal: true

module TargetsHelper
  def estimated_usage_for(school, fuel_type)
    return nil unless school.configuration.estimated_consumption_for_fuel_type(fuel_type).present?

    FormatUnit.format(:kwh, school.configuration.estimated_consumption_for_fuel_type(fuel_type), :html, false, true,
                      :target)
  end

  def estimate_to_low?(school, value, fuel_type)
    estimate = school.configuration.estimated_consumption_for_fuel_type(fuel_type)
    return '' unless estimate.present? && value.present?

    value < estimate ? 'text-danger' : ''
  end

  def meeting_target_text(meeting_target, fuel_type)
    t("schools.show.#{meeting_target ? :making_progress : :not_meeting_target}",
      fuels: t("advice_pages.fuel_type.#{fuel_type}"))
  end
end

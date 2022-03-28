module TargetsHelper
  def show_limited_data?(school_target, fuel_type)
    EnergySparks::FeatureFlags.active?(:school_targets_v2) && school_target[fuel_type].present?
  end

  def show_prompt_for_estimates?(fuel_types_with_estimate_suggestions, fuel_type = nil)
    if fuel_types_with_estimate_suggestions.present? && fuel_types_with_estimate_suggestions.any?
      if fuel_type.present?
        fuel_types_with_estimate_suggestions.include?(fuel_type.to_s)
      else
        true
      end
    else
      false
    end
  end
end

module TargetsHelper
  def show_limited_data?(school_target, fuel_type)
    EnergySparks::FeatureFlags.active?(:school_targets_v2) && school_target[fuel_type].present?
  end
end

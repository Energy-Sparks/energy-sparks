# frozen_string_literal: true

module SchoolGroupAdvice
  def set_fuel_types
    @fuel_types = @school_group.fuel_types(@schools)
  end

  def set_counts
    @priority_actions_service = SchoolGroups::PriorityActions.new(@schools)
    @alerts_service = SchoolGroups::Alerts.new(@schools)
  end
end

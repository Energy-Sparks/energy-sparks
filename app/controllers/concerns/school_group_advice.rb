# frozen_string_literal: true

module SchoolGroupAdvice
  def set_fuel_types
    @fuel_types = @school_group.fuel_types
  end

  def set_counts
    @priority_action_count = SchoolGroups::PriorityActions.new(@schools).priority_action_count
    @alert_count = SchoolGroups::Alerts.new(@schools).summarise.count
  end

  def set_all_group_advice_vars
    set_fuel_types
    load_schools
    set_counts
  end
end

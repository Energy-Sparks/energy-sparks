module SchoolProgress
  extend ActiveSupport::Concern

private

  def redirect_if_disabled
    redirect_to school_path(@school) unless Targets::SchoolTargetService.targets_enabled?(@school) && Targets::SchoolTargetService.new(@school).enough_data?
  end

  def prompt_for_target?
    return false unless can?(:show_management_dash, @school)
    Targets::SchoolTargetService.targets_enabled?(@school) && can?(:manage, SchoolTarget) && !@school.has_target? && target_service.enough_data?
  end

  def prompt_to_review_target?
    return false unless can?(:show_management_dash, @school)
    Targets::SchoolTargetService.targets_enabled?(@school) && can?(:manage, SchoolTarget) && target_service.prompt_to_review_target?
  end

  def prompt_to_set_new_target?
    return false unless can?(:show_management_dash, @school)
    Targets::SchoolTargetService.targets_enabled?(@school) && can?(:manage, SchoolTarget) && @school.has_expired_target? && !@school.has_current_target?
  end

  def fuel_types_changed
    return nil unless @school.has_target?
    @school.most_recent_target.revised_fuel_types
  end

  def target_service
    @target_service ||= Targets::SchoolTargetService.new(@school)
  end
end

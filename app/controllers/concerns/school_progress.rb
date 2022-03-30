module SchoolProgress
  extend ActiveSupport::Concern

private

  def redirect_if_disabled
    redirect_to school_path(@school) unless Targets::SchoolTargetService.targets_enabled?(@school) && Targets::SchoolTargetService.new(@school).enough_data?
  end

  def prompt_for_target?
    Targets::SchoolTargetService.targets_enabled?(@school) && can?(:manage, SchoolTarget) && !@school.has_target? && target_service.enough_data?
  end

  def prompt_to_review_target?
    Targets::SchoolTargetService.targets_enabled?(@school) && can?(:manage, SchoolTarget) && target_service.prompt_to_review_target?
  end

  def suggest_estimates_for_fuel_types(check_data: false)
    if EnergySparks::FeatureFlags.active?(:school_targets_v2) && can?(:manage, EstimatedAnnualConsumption)
      Targets::SuggestEstimatesService.new(@school).suggestions(check_data: check_data)
    else
      []
    end
  end

  def suggest_estimate_for_fuel_type?(fuel_type, check_data: false)
    pry
    if EnergySparks::FeatureFlags.active?(:school_targets_v2) && can?(:manage, EstimatedAnnualConsumption)
      Targets::SuggestEstimatesService.new(@school).suggest_for_fuel_type?(fuel_type, check_data: check_data)
    else
      false
    end
  end

  def fuel_types_changed
    return nil unless @school.has_target?
    @school.most_recent_target.revised_fuel_types
  end

  def progress_service
    @progress_service ||= Targets::ProgressService.new(@school)
  end

  def target_service
    @target_service ||= Targets::SchoolTargetService.new(@school)
  end
end

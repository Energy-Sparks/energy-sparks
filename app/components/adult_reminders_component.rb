class AdultRemindersComponent < DashboardRemindersComponent
  def messageable
    [@school, @school.try(:school_group)].compact
  end

  def prompt_for_bill?
    can_manage_school? && @school.bill_requested && can?(:index, ConsentDocument)
  end

  def prompt_for_training?
    can_manage_school? && show_data_enabled_features? && user.confirmed_at > 30.days.ago
  end

  def prompt_for_contacts?
    site_settings.message_for_no_contacts && @school.contacts.empty? && can?(:manage, Contact)
  end

  def prompt_for_pupils?
    site_settings.message_for_no_pupil_accounts && @school.users.pupil.empty? && can?(:manage_users, @school)
  end

  def recent_audit
    Audits::AuditService.new(@school).recent_audit
  end

  def prompt_for_target?
    Targets::SchoolTargetService.targets_enabled?(@school) && can?(:manage, SchoolTarget) && !@school.has_target? && target_service.enough_data?
  end

  def prompt_to_review_target?
    Targets::SchoolTargetService.targets_enabled?(@school) && can?(:manage, SchoolTarget) && target_service.prompt_to_review_target?
  end

  def prompt_to_set_new_target?
    Targets::SchoolTargetService.targets_enabled?(@school) && can?(:manage, SchoolTarget) && @school.has_expired_target? && !@school.has_current_target?
  end

  def suggest_estimates_for_fuel_types(check_data: true)
    if can?(:manage, EstimatedAnnualConsumption)
      Targets::SuggestEstimatesService.new(@school).suggestions(check_data: check_data)
    else
      []
    end
  end

  private

  def site_settings
    @site_settings ||= SiteSettings.current
  end

  def target_service
    @target_service ||= Targets::SchoolTargetService.new(@school)
  end
end

class AdultRemindersComponent < DashboardRemindersComponent
  include SchoolProgress

  def show_standard_prompts?
    user&.admin? || can_manage_school?
  end

  def can_manage_school?
    ability.can?(:show_management_dash, @school)
  end

  def messageable
    [@school, @school.try(:school_group)].compact
  end

  def prompt_for_bill?
    can_manage_school? && @school.bill_requested && ability.can?(:index, ConsentDocument)
  end

  def prompt_for_training?
    return false if user && user.admin?
    can_manage_school? && show_data_enabled_features? && user.confirmed_at > 30.days.ago
  end

  def prompt_for_contacts?
    site_settings.message_for_no_contacts && can_manage_school? && @school.contacts.empty? && ability.can?(:manage, Contact)
  end

  def prompt_for_pupils?
    site_settings.message_for_no_pupil_accounts && @school.users.pupil.empty? && ability.can?(:manage_users, @school)
  end

  def recent_audit
    Audits::AuditService.new(@school).recent_audit
  end

  private

  def site_settings
    @site_settings ||= SiteSettings.current
  end
end

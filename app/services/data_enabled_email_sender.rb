class DataEnabledEmailSender
  def initialize(school)
    @school = school
  end

  def send
    unless @school.has_school_onboarding_event?(:data_enabled_email_sent)
      users = @school.activation_users
      if users.any?
        target_prompt = include_target_prompt_in_email?
        OnboardingMailer.with_user_locales(users: users, school: @school, target_prompt: target_prompt) { |mailer| mailer.data_enabled_email.deliver_now }

        onboarding_service.record_event(@school.school_onboarding, :data_enabled_email_sent)
        record_target_event(@school, :first_target_sent) if target_prompt
      end
    end
  end

  private

  def include_target_prompt_in_email?
    Targets::SchoolTargetService.targets_enabled?(@school) && Targets::SchoolTargetService.new(@school).enough_data?
  end

  def record_target_event(school, event)
    school.school_target_events.create(event: event)
  end

  def onboarding_service
    @onboarding_service ||= Onboarding::Service.new
  end
end

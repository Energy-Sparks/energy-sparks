class ActivationEmailSender
  def initialize(school)
    @school = school
  end

  def send
    unless @school.has_school_onboarding_event?(:activation_email_sent)
      to = @school.activation_email_list
      if to.any?
        target_prompt = include_target_prompt_in_email?
        OnboardingMailer.with(to: to, school: @school, target_prompt: target_prompt).activation_email.deliver_now

        onboarding_service.record_event(@school.school_onboarding, :activation_email_sent)
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

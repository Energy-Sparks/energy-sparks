class ActivationEmailSender
  include OnboardingHelper

  def initialize(school)
    @school = school
  end

  def send
    if should_send_activation_email?(@school)
      to = @school.activation_email_list
      if to.any?
        target_prompt = include_target_prompt_in_email?
        OnboardingMailer.with(to: to, school: @school, target_prompt: target_prompt).activation_email.deliver_now

        record_event(@school.school_onboarding, :activation_email_sent) unless @school.school_onboarding.nil?
        record_target_event(@school, :first_target_sent) if target_prompt
      end
    end
  end

  private

  def should_send_activation_email?(school)
    school.school_onboarding.nil? || school.school_onboarding && !school.school_onboarding.has_event?(:activation_email_sent)
  end

  def include_target_prompt_in_email?
    return Targets::SchoolTargetService.targets_enabled?(@school) && Targets::SchoolTargetService.new(@school).enough_data?
  end

  def record_target_event(school, event)
    school.school_target_events.create(event: event)
  end
end

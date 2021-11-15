class DataEnabledEmailSender
  include OnboardingHelper

  def initialize(school)
    @school = school
  end

  def send
    unless @school.has_school_onboarding_event?(:data_enabled_email_sent)
      to = @school.activation_email_list
      if to.any?
        target_prompt = include_target_prompt_in_email?
        OnboardingMailer.with(to: to, school: @school, target_prompt: target_prompt).data_enabled_email.deliver_now

        record_event(@school.school_onboarding, :data_enabled_email_sent)
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
end

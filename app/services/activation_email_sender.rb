class ActivationEmailSender
  def initialize(school)
    @school = school
  end

  def send
    if should_send_activation_email?
      to = activation_email_list(@school)
      if to.any?
        target_prompt = include_target_prompt_in_email?
        OnboardingMailer.with(to: to, school: @school, target_prompt: target_prompt).activation_email.deliver_now

        record_event(@school.school_onboarding, :activation_email_sent) unless @school.school_onboarding.nil?
        record_target_event(@school, :first_target_sent) if target_prompt
      end
    end
  end

  private

  def should_send_activation_email?
    @school.school_onboarding.nil? || @school.school_onboarding && !@school.school_onboarding.has_event?(:activation_email_sent)
  end

  def activation_email_list(school)
    users = []
    if school.school_onboarding && school.school_onboarding.created_user.present?
      users << school.school_onboarding.created_user
    end
    #also email admin, staff and group users
    users += school.all_adult_school_users.to_a
    users.uniq.map(&:email)
  end

  def include_target_prompt_in_email?
    return Targets::SchoolTargetService.targets_enabled?(@school) && Targets::SchoolTargetService.new(@school).enough_data?
  end

  def should_complete_onboarding?
    @school.school_onboarding && @school.school_onboarding.incomplete?
  end

  def record_event(onboarding, *events)
    result = yield if block_given?
    events.each do |event|
      onboarding.events.create(event: event)
    end
    result
  end
  alias_method :record_events, :record_event

  def record_target_event(school, event)
    school.school_target_events.create(event: event)
  end
end

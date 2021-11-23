class OnboardedEmailSender
  def initialize(school)
    @school = school
  end

  def send
    unless @school.has_school_onboarding_event?(:onboarded_email_sent)
      to = @school.activation_email_list
      if to.any?
        OnboardingMailer.with(to: to, school: @school).onboarded_email.deliver_now
        onboarding_service.record_event(@school.school_onboarding, :onboarded_email_sent)
      end
    end
  end

  private

  def onboarding_service
    @onboarding_service ||= Onboarding::Service.new
  end
end

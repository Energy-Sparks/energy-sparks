class OnboardedEmailSender
  def initialize(school)
    @school = school
  end

  def send
    unless @school.has_school_onboarding_event?(:onboarded_email_sent)
      users = @school.activation_users
      if users.any?
        OnboardingMailer.with_user_locales(users: users, school: @school) { |mailer| mailer.onboarded_email.deliver_now }
        onboarding_service.record_event(@school.school_onboarding, :onboarded_email_sent)
      end
    end
  end

  private

  def onboarding_service
    @onboarding_service ||= Onboarding::Service.new
  end
end

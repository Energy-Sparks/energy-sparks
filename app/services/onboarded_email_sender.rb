# frozen_string_literal: true

class OnboardedEmailSender
  def initialize(school)
    @school = school
  end

  def send
    return if @school.has_school_onboarding_event?(:onboarded_email_sent)

    users = @school.activation_users
    return unless users.any?

    mailer = Flipper.enabled?(:onboarding_mailer_2025) ? OnboardingMailer2025 : OnboardingMailer
    mailer.with_user_locales(users: users, school: @school) do |mailer|
      mailer.onboarded_email.deliver_now
    end
    onboarding_service.record_event(@school.school_onboarding, :onboarded_email_sent)
  end

  private

  def onboarding_service
    @onboarding_service ||= Onboarding::Service.new
  end
end

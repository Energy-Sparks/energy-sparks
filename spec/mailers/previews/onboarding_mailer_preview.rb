class OnboardingMailerPreview < ActionMailer::Preview
  def onboarding_email
    OnboardingMailer.with(school_onboarding: SchoolOnboarding.complete.first, locale: locale).onboarding_email
  end

  def completion_email
    OnboardingMailer.with(school_onboarding: SchoolOnboarding.complete.first, locale: locale).completion_email
  end

  def reminder_email
    OnboardingMailer.with(email: 'test@test.com', school_onboardings: [SchoolOnboarding.incomplete.first], locale: locale).reminder_email
  end

  def onboarded_email
    OnboardingMailer.with(school: School.visible.first, users: School.visible.first.users.school_admin, locale: locale).onboarded_email
  end

  def data_enabled_email
    OnboardingMailer.with(school: School.visible.first, users: School.visible.first.users.school_admin, target_prompt: true, locale: locale).data_enabled_email
  end

  def welcome_email
    OnboardingMailer.with(school: School.visible.first, users: School.visible.first.users.school_admin, locale: locale).welcome_email
  end

  private

  def locale
    @params['locale'].present? ? @params['locale'] : 'en'
  end
end

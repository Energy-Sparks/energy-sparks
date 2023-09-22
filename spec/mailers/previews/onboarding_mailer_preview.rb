class OnboardingMailerPreview < ActionMailer::Preview
  def onboarding_email
    OnboardingMailer.with(school_onboarding: SchoolOnboarding.complete.first).onboarding_email
  end

  def completion_email
    OnboardingMailer.with(school_onboarding: SchoolOnboarding.complete.first).completion_email
  end

  def reminder_email
    OnboardingMailer.with(school_onboarding: SchoolOnboarding.complete.first).reminder_email
  end

  def activation_email
    OnboardingMailer.with(school: School.visible.first, users: School.visible.first.users.school_admin).activation_email
  end

  def onboarded_email
    OnboardingMailer.with(school: School.visible.first, users: School.visible.first.users.school_admin).onboarded_email
  end

  def data_enabled_email
    OnboardingMailer.with(school: School.visible.first, users: School.visible.first.users.school_admin, target_prompt: true).data_enabled_email
  end

  def welcome_email
    OnboardingMailer.with(school: School.visible.first, users: School.visible.first.users.school_admin).welcome_email
  end

end

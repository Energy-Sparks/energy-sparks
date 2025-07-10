# frozen_string_literal: true

class OnboardingMailer2025Preview < ActionMailer::Preview
  def onboarded_email
    OnboardingMailer2025.with(school: School.visible.first,
                              users: School.visible.first.users.school_admin,
                              locale:).onboarded_email
  end

  def welcome_email_school_admin
    user = User.school_admin.joins(:school).where(schools: { visible: true, data_enabled: false }).sample
    OnboardingMailer2025.with(school: user.school, user:, locale:).welcome_email
  end

  def welcome_email_staff
    user = User.staff.joins(:school).where(schools: { visible: true, data_enabled: false }).sample
    OnboardingMailer2025.with(school: user.school, user:, locale:).welcome_email
  end

  private

  def locale
    @params['locale'].presence || 'en'
  end
end

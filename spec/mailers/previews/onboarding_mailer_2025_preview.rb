# frozen_string_literal: true

class OnboardingMailer2025Preview < ActionMailer::Preview
  def onboarded_email
    OnboardingMailer2025.with(school: School.visible.first,
                              users: School.visible.first.users.school_admin,
                              locale:).onboarded_email
  end

  private

  def locale
    @params['locale'].presence || 'en'
  end
end

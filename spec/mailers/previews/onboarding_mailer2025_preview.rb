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

  def welcome_email_data_visible
    user = User.joins(:school).where(schools: { visible: true, data_enabled: true }).sample
    OnboardingMailer2025.with(school: user.school, user:, locale:).welcome_email
  end

  def self.welcome_existing_params
    { school_id: DashboardMessage.where(messageable_type: :School).sample.messageable_id }
  end

  def welcome_existing
    school = School.find(params[:school_id])
    OnboardingMailer2025.with(school:, user: school.users.sample, locale:).welcome_existing
  end

  private

  def locale
    @params['locale'].presence || 'en'
  end
end

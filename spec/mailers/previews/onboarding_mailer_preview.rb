# frozen_string_literal: true

class OnboardingMailerPreview < ActionMailer::Preview
  def onboarded_email
    OnboardingMailer.with(school: School.visible.first,
                              users: School.visible.first.users.school_admin,
                              locale:).onboarded_email
  end

  def self.welcome_email_params(users, data_enabled)
    { user_id: users.joins(:school).where(schools: { visible: true, data_enabled: }).sample&.id }
  end

  def self.welcome_email_school_admin_params
    welcome_email_params(User.school_admin, false)
  end

  def welcome_email_school_admin
    user = User.find(params[:user_id])
    OnboardingMailer.with(school: user.school, user:, locale:).welcome_email
  end

  def self.welcome_email_staff_params
    welcome_email_params(User.staff, false)
  end

  def welcome_email_staff
    welcome_email_school_admin
  end

  def self.welcome_email_data_visible_params
    welcome_email_params(User, true)
  end

  def welcome_email_data_visible
    welcome_email_school_admin
  end

  def self.welcome_existing_params
    { school_id: DashboardMessage.where(messageable_type: :School).sample&.messageable_id }
  end

  def welcome_existing
    school = School.find(params[:school_id])
    OnboardingMailer.with(school:, user: school.users.sample, locale:).welcome_existing
  end

  def self.data_enabled_email_admin_params
    { school_id: DashboardMessage.where(messageable_type: :School)
                                 .joins('JOIN schools ON schools.id = dashboard_messages.messageable_id AND ' \
                                        'schools.visible AND schools.data_enabled').sample&.messageable_id }
  end

  def data_enabled_email_admin
    school = School.find(params[:school_id])
    OnboardingMailer.with(school:, users: school.users.school_admin, locale:).data_enabled_email
  end

  def self.data_enabled_email_staff_params
    data_enabled_email_admin_params
  end

  def data_enabled_email_staff
    school = School.find(params[:school_id])
    OnboardingMailer.with(school:, users: school.users.staff, locale:, staff: true).data_enabled_email
  end

  private

  def locale
    @params['locale'].presence || 'en'
  end
end

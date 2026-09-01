# frozen_string_literal: true

class SolarEdgeMailerPreview < ActionMailer::Preview
  def request_connection
    locale = @params['locale'].presence || 'en'
    SolarEdgeMailer.with(users: School.first.users, school: School.first, locale: locale).request_connection
  end

  def notify_admin
    SolarEdgeMailer.notify_admin(SolarEdgeInstallation.all.sample)
  end
end

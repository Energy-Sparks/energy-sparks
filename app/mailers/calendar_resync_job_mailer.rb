# frozen_string_literal: true

class CalendarResyncJobMailer < ApplicationMailer
  helper :application
  layout 'admin_mailer'

  def complete
    to, @resync_service = params.values_at(:to, :resync_service)
    mail(to:, subject: "[energy-sparks-#{env}] " \
                       "#{I18n.t('calendars.show.title', calendar_title: @resync_service.calendar.title)} " \
                       'resync complete')
  end
end

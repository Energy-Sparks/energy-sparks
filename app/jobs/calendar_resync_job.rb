# frozen_string_literal: true

class CalendarResyncJob < ApplicationJob
  queue_as :default

  def perform(calendar, from_date, notify_email)
    resync_service = CalendarResyncService.new(calendar, from_date)
    resync_service.resync
    CalendarResyncJobMailer.with(to: notify_email, resync_service:).complete.deliver
  end
end

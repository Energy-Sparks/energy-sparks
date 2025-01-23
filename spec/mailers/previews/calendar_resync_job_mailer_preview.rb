class CalendarResyncJobMailerPreview < ActionMailer::Preview
  def complete
    resync_service = CalendarResyncService.new(School.visible.first.calendar)
    # resync_service.resync
    CalendarResyncJobMailer.with(to: 'test@example.com', resync_service:).complete
  end
end

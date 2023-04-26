class AlertMailerPreview < ActionMailer::Preview
  def alert_email
    AlertMailer.with(email_address: 'test@blah.com', school: AlertSubscriptionEvent.last.alert.school, events: [AlertSubscriptionEvent.last], target_prompt: nil).alert_email
  end
end

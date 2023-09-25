class AlertMailerPreview < ActionMailer::Preview
  def alert_email
    AlertMailer.with(email_address: 'test@blah.com', school: AlertSubscriptionEvent.last.alert.school, events: [AlertSubscriptionEvent.last], target_prompt: nil, locale: locale).alert_email
  end

  private

  def locale
    locale = @params["locale"].present? ? @params["locale"] : "en"
  end
end

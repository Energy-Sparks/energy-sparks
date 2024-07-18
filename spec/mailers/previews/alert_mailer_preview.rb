class AlertMailerPreview < ActionMailer::Preview
  def alert_email
    if @params[:email].present?
      AlertMailer.with(**preview_existing_email).alert_email
    else
      AlertMailer.with(email_address: 'test@blah.com', school: AlertSubscriptionEvent.last.alert.school, events: [AlertSubscriptionEvent.last], target_prompt: nil, locale: locale).alert_email
    end
  end

  private

  def locale
    @params['locale'].present? ? @params['locale'] : 'en'
  end

  def include_target_prompt_in_email?(school)
    return Targets::SchoolTargetService.targets_enabled?(school) && Targets::SchoolTargetService.new(school).enough_data?
  end

  def preview_existing_email
    email = Email.find(@params[:email])
    school = email.contact.school
    {
      email_address: email.contact.email_address,
      school: school,
      events: email.alert_subscription_events.by_priority,
      target_prompt: include_target_prompt_in_email?(school),
      unsubscribe_emails: User.where(school: school, role: :school_admin).pluck(:email).join(', '),
      locale: locale
    }
  end
end

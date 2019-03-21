class AlertMailerPreview < ActionMailer::Preview
  def alert_email
    @unsubscribe_emails = User.where(school_id: params[:school_id], role: :school_admin).pluck(:email).join(', ')
    AlertMailer.with(email_address: params[:email_address], alert_ids: params[:alert_ids], school_id: params[:school_id]).alert_email
  end

  def self.custom_url(school_id, email_address, message_id)
    alert_ids = get_all_the_alert_ids_for_message(message_id)
    "/rails/mailers/alert_mailer/alert_email?school_id=#{school_id}&email_address=#{email_address}&alert_ids=[#{alert_ids}]"
  end

  def self.get_all_the_alert_ids_for_message(message_id)
    return "" unless message_id
    AlertSubscriptionEvent.where(message_id: message_id).pluck(:alert_id)
  end
end

module NewsletterSubscriber
  extend ActiveSupport::Concern

  private

  def subscribe_newsletter(user)
    MailchimpSubscriber.new(MailchimpApi.new).subscribe(user)
  rescue MailchimpSubscriber::Error => e
    Rails.logger.error e.backtrace.join("\n")
    Rollbar.error(e, school_id: user.school_id, school_name: user.school_name)
  end

  def auto_subscribe_newsletter?
    params[:user] && params[:user].key?(:auto_subscribe_newsletter)
  end
end

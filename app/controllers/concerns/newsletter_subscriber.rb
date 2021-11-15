module NewsletterSubscriber
  extend ActiveSupport::Concern

  private

  def subscribe_newsletter(school, user)
    MailchimpSubscriber.new(MailchimpApi.new).subscribe(school, user)
  rescue MailchimpSubscriber::Error => e
    Rails.logger.error e.backtrace.join("\n")
    Rollbar.error(e, school_id: school.id, school_name: school.name)
  end

  def auto_subscribe_newsletter?
    params[:user] && params[:user].key?(:auto_subscribe_newsletter)
  end
end

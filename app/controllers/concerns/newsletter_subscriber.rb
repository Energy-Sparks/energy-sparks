module NewsletterSubscriber
  extend ActiveSupport::Concern

  private

  def subscribe_newsletter(user)
    MailchimpSubscriber.new(MailchimpApi.new).subscribe(user)
  rescue MailchimpSubscriber::Error => e
    Rails.logger.error e.backtrace.join("\n")
    school_id = user.school ? user.school.id : ''
    school_name = user.school ? user.school.name : ''
    Rollbar.error(e, school_id: school_id, school_name: school_name)
  end

  def auto_subscribe_newsletter?
    params[:user] && params[:user].key?(:auto_subscribe_newsletter)
  end
end

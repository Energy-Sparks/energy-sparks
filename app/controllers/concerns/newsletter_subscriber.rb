module NewsletterSubscriber
  extend ActiveSupport::Concern

  private

  def user_subscribed_to_newsletter?(school_onboarding, user)
    school_onboarding.subscribe_users_to_newsletter.include?(user.id)
  end

  def change_user_subscribed_to_newsletter(school_onboarding, user, subscribe)
    if subscribe
      school_onboarding.subscribe_users_to_newsletter << user.id unless user_subscribed_to_newsletter?(school_onboarding, user)
    else
      school_onboarding.subscribe_users_to_newsletter.delete(user.id)
    end
    school_onboarding.save!
  end

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

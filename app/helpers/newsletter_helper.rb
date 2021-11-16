module NewsletterHelper
  def user_subscribed_to_newsletter?(school_onboarding, user)
    school_onboarding.subscribe_users_to_newsletter.include?(user.id)
  end
end

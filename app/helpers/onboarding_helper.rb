module OnboardingHelper
  def change_user_subscribed_to_newsletter(onboarding, user, subscribe)
    if subscribe
      onboarding.subscribe_users_to_newsletter << user.id unless user_subscribed_to_newsletter?(onboarding, user)
    else
      onboarding.subscribe_users_to_newsletter.delete(user.id)
    end
    onboarding.save!
  end

  def user_subscribed_to_newsletter?(onboarding, user)
    onboarding.subscribe_users_to_newsletter.include?(user.id)
  end
end

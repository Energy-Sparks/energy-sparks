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

  def send_confirmation_instructions(users)
    #confirm other users created during onboarding
    users.each do |user|
      user.send_confirmation_instructions unless user.confirmed?
    end
  end

  def create_additional_contacts(school_onboarding, users)
    users.each do |user|
      school_onboarding.events.create(event: :alert_contact_created)
      school_onboarding.school.contacts.create!(
        user: user,
        name: user.display_name,
        email_address: user.email,
        description: 'School Energy Sparks contact'
      )
    end
  end

  def subscribe_users_to_newsletter(school_onboarding, users)
    users.each do |user|
      subscribe_newsletter(school_onboarding.school, user) if user_subscribed_to_newsletter?(school_onboarding, user)
    end
  end

  def should_send_activation_email?(school)
    school.school_onboarding.nil? || school.school_onboarding && !school.school_onboarding.has_event?(:activation_email_sent)
  end

  def should_complete_onboarding?(school)
    school.school_onboarding && school.school_onboarding.incomplete?
  end
end

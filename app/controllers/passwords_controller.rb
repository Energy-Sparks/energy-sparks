class PasswordsController < Devise::PasswordsController
  before_action :set_confirmed

  include AlertContactCreator
  include NewsletterSubscriber

  def update
    super do |user|
      if user.valid?
        create_or_update_alert_contact(user.school, user) if auto_create_alert_contact?
        subscribe_newsletter(user.school, user) if auto_subscribe_newsletter?
      end
    end
  end

  private

  def set_confirmed
    @confirmed = params[:confirmed].present?
  end
end

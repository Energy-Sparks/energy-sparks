class PasswordsController < Devise::PasswordsController
  before_action :set_confirmed

  include AlertContactCreator
  include NewsletterSubscriber

  def update
    super do |user|
      if user.valid?
        subscribe_newsletter(user.school, user) if resource_params[:auto_subscribe_newsletter]
        create_or_update_alert_contact(user.school, user) if auto_create_alert_contact?
      end
    end
  end

  private

  def set_confirmed
    @confirmed = params[:confirmed].present?
  end
end

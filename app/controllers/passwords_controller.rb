class PasswordsController < Devise::PasswordsController
  before_action :set_confirmed
  before_action :set_email_types

  include AlertContactCreator
  include NewsletterSubscriber

  def edit
    super
    # the resource is NOT the actual user - have to find it ourselves
    user = User.with_reset_password_token(params[:reset_password_token])
    if user
      @show_newletter_options = show_newletter_options?(user)
      @allow_alerts = allow_alerts?(user)
      @subscribe_alerts = true
      @subscribe_newsletters = true
      resource.preferred_locale = user.preferred_locale
    else
      redirect_to new_user_password_path, notice: t('errors.messages.reset_password_token_is_invalid') and return
    end
  end

  def update
    super do |user|
      @show_newletter_options = show_newletter_options?(user)
      @allow_alerts = allow_alerts?(user)
      @subscribe_alerts = auto_create_alert_contact?
      @subscribe_newsletters = subscribe_newsletter?
      user.preferred_locale = resource_params[:preferred_locale] if resource_params[:preferred_locale]
      if user.errors.empty?
        create_or_update_alert_contact(user.school, resource) if @subscribe_alerts
        subscribe_newsletter(user, params.permit(interests: {})) if @subscribe_newsletters
      end
    end
  end

  private

  def set_email_types
    @email_types = list_of_email_types
  end

  def set_confirmed
    @confirmed = (params[:confirmed] == 'true')
  end

  def subscribe_newsletter?
    params[:user] && params[:interests]&.value?('true')
  end

  def show_newletter_options?(user)
    @confirmed && user.present? && (user.school.present? || user.school_group.present?)
  end

  def allow_alerts?(user)
    @confirmed && user.present? && user.school.present?
  end

  def subscribe_newsletter(user, sign_up_params)
    contact = create_contact_from_user(user, sign_up_params)
    subscribe_contact(contact, user, show_errors: false)
  end
end

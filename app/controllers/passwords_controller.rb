class PasswordsController < Devise::PasswordsController
  before_action :set_confirmed

  include AlertContactCreator
  include NewsletterSubscriber

  def edit
    super
    # the resource is NOT the actual user - have to find it ourselves
    user = User.with_reset_password_token(params[:reset_password_token])
    if user
      @allow_newsletters = allow_newletters?(user)
      @allow_alerts = allow_alerts?(user)
      @subscribe_alerts = true
      @subscribe_newsletters = true
      resource.preferred_locale = user.preferred_locale
    else
      redirect_to new_user_password_path, notice: t('errors.messages.reset_password_token_is_invalid') and return
    end
  end

  def update
    super do |resource|
      @allow_newsletters = allow_newletters?(resource)
      @allow_alerts = allow_alerts?(resource)
      @subscribe_alerts = auto_create_alert_contact?
      @subscribe_newsletters = auto_subscribe_newsletter?
      resource.preferred_locale = resource_params[:preferred_locale] if resource_params[:preferred_locale]
      if resource.errors.empty?
        create_or_update_alert_contact(resource.school, resource) if @subscribe_alerts
        subscribe_newsletter(resource) if @subscribe_newsletters
      end
    end
  end

  private

  def set_confirmed
    @confirmed = (params[:confirmed] == 'true')
  end

  def allow_newletters?(user)
    @confirmed && user.present? && (user.school.present? || user.school_group.present?)
  end

  def allow_alerts?(user)
    @confirmed && user.present? && user.school.present?
  end
end

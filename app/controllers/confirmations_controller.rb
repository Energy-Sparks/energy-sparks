class ConfirmationsController < Devise::ConfirmationsController
  include AlertContactCreator
  include NewsletterSubscriber

  before_action :set_minimum_password_length, only: [:show, :confirm]
  before_action :set_email_types

  helper_method :subscribe_to_alerts?

  def show
    return head(:ok) if request.head?

    self.resource = resource_class.find_by(confirmation_token: params[:confirmation_token])

    if resource.nil?
      redirect_to new_user_confirmation_path and return
    elsif resource.confirmed? && current_user.nil?
      flash[:error] = I18n.t('errors.messages.already_confirmed')
      redirect_to new_session_path(resource_name) and return
    elsif resource.confirmed? && current_user
      flash[:error] = I18n.t('devise.failure.already_authenticated')
      redirect_to after_sign_in_path_for(resource) and return
    else
      set_form_options(resource, true)
      render :show
    end
  end

  def confirm
    self.resource = resource_class.find_by(confirmation_token: params[:confirmation_token])

    if resource.nil?
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :show }
      return
    end

    resource.assign_attributes(
      confirmed_at: Time.zone.now, # setting confirmed means password validation is now active
      password: resource_params[:password],
      password_confirmation: resource_params[:password_confirmation],
      preferred_locale: resource_params[:preferred_locale] || 'en',
      terms_accepted: resource_params[:terms_accepted]
    )

    if resource.valid? && resource.terms_accepted
      resource.save

      subscribe_to_emails(resource)
      devise_sign_in(resource)

      flash[:success] = I18n.t('devise.confirmations.confirmed')
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      set_form_options(resource, false)
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :show }
    end
  end

  private

  def set_form_options(resource, default_interests)
    @allow_alerts = allow_alerts?(resource)
    @can_subscribe_newsletter = can_subscribe_newsletter?(resource)
    if @can_subscribe_newsletter
      @interests = default_interests ? default_interests(resource) : interests_from_params
    end
  end

  def interests_from_params
    params.permit(interests: {}).to_h['interests'].transform_values { |v| v == 'true' }
  end

  def subscribe_to_emails(resource)
    create_or_update_alert_contact(resource.school, resource) if subscribe_to_alerts?
    subscribe_newsletter(resource, params.permit(interests: {})) if can_subscribe_newsletter?(resource)
  end

  # Same as usual Devise sign-in step following resetting password
  def devise_sign_in(resource)
    resource.after_database_authentication
    sign_in(resource_name, resource)
  end

  def after_resetting_password_path_for(resource)
    resource_class.sign_in_after_reset_password ? after_sign_in_path_for(resource) : new_session_path(resource_name)
  end

  def allow_alerts?(resource)
    resource&.school&.present?
  end

  def can_subscribe_newsletter?(resource)
    !resource&.student_user?
  end

  def subscribe_newsletter(resource, sign_up_params)
    contact = create_contact_from_user(resource, sign_up_params)
    subscribe_contact(contact, resource, show_errors: false)
  end
end

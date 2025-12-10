class ConfirmationsController < Devise::ConfirmationsController
  include AlertContactCreator
  include NewsletterSubscriber

  before_action :set_minimum_password_length, only: [:show, :confirm]
  before_action :set_email_types

  def show
    return head(:ok) if request.head?

    self.resource = resource_class.find_by(confirmation_token: params[:confirmation_token])

    if resource.nil?
      # FIXME add flash notice?
      redirect_to new_user_confirmation_path and return
    elsif resource.confirmed? && current_user.nil?
      redirect_to new_session_path(resource_name) and return
    elsif resource.confirmed? && current_user
      redirect_to after_sign_in_path_for(resource) and return
    else
      @allow_alerts = allow_alerts?(resource)
      @can_subscribe_newsletter = can_subscribe_newsletter?(resource)
      @interests = default_interests(resource) if @can_subscribe_newsletter
      render :show
    end
  end

  def confirm
    self.resource = resource_class.find_by(confirmation_token: params[:confirmation_token])

    # FIXME write spec for this, and if already confirmed?
    if resource.nil?
      set_flash_message!(:alert, :invalid_token)
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :show }
      return
    end

    # FIXME Save this don't use virtual attribute
    resource.assign_attributes(
      password: resource_params[:password],
      password_confirmation: resource_params[:password_confirmation],
      terms_accepted: resource_params[:terms_accepted],
      preferred_locale: resource_params[:preferred_locale] || 'en'
    )

    if resource.valid? && resource.terms_accepted == '1'
      resource.confirm
      resource.save
      # FIXME update translations
      # FIXME add a message?
      #      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      #      set_flash_message!(:notice, flash_message)

      create_or_update_alert_contact(resource.school, resource) if subscribe_to_alerts?
      subscribe_newsletter(resource, params.permit(interests: {})) if can_subscribe_newsletter?(resource)

      resource.after_database_authentication
      sign_in(resource_name, resource)

      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      @allow_alerts = allow_alerts?(resource)
      @can_subscribe_newsletter = can_subscribe_newsletter?(resource)
      @interests = default_interests(resource) if @can_subscribe_newsletter

      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :show }
    end
  end

  private

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

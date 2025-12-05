class ConfirmationsController < Devise::ConfirmationsController
  include AlertContactCreator
  include NewsletterSubscriber

  before_action :set_minimum_password_length, only: [:show, :confirm]
  before_action :set_email_types

  def show
    return head(:ok) if request.head?

    self.resource = resource_class.find_by(confirmation_token: params[:confirmation_token])
    if resource.nil?
      # FIXME add flash message? e.g. set_flash_message!(:notice, :invalid_token)
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    else
      @allow_alerts = resource&.school&.present?
      @can_subscribe_newsletter = !resource&.student_user?
      @interests = default_interests(resource) if @can_subscribe_newsletter
      render :show
    end
  end

  def confirm
    self.resource = resource_class.find_by(confirmation_token: params[:confirmation_token])

    if resource.nil?
      set_flash_message!(:alert, :invalid_token)
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :show }
      return
    end

    resource.password              = params[:user][:password]
    resource.password_confirmation = params[:user][:password_confirmation]
    # FIXME Save this don't use virtual attribute
    resource.terms_accepted        = params[:user][:terms_accepted]

    if resource.valid? && resource.terms_accepted == '1'
      resource.confirm
      resource.save
      # FIXME message says email "Your password has been changed successfully. You are now signed in."
      # where is this set?
      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      @allow_alerts = resource&.school&.present?
      @can_subscribe_newsletter = !resource&.student_user?
      @interests = default_interests(resource) if @can_subscribe_newsletter

      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :show }
    end
  end

  private

  def set_email_types
    @email_types = list_of_email_types
  end

  def after_confirmation_path_for(_resource_name, resource)
    token = resource.send(:set_reset_password_token)
    edit_password_url(resource, reset_password_token: token, confirmed: true)
  end
end

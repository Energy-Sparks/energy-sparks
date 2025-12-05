class ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  # HEAD request on confirmation URL must not confirm the user
  def show
    request.head? ? head(:ok) : super
  end

  private

  def after_confirmation_path_for(_resource_name, resource)
    token = resource.send(:set_reset_password_token)
    edit_password_url(resource, reset_password_token: token, confirmed: true)
  end
end

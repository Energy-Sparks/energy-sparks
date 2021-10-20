class SignInAndRedirectController < ApplicationController
  skip_before_action :authenticate_user!

  def redirect
    origin = params[:url]
    #store redirect if present and its a relative path. don't silently redirect to external sites
    store_location_for(:user, origin) if origin.present? && origin.start_with?("/")
    redirect_to new_user_session_path
  end
end

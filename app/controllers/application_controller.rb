class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_ga_code

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

private

  def set_ga_code
    @analytics_code = ENV['GOOGLE_ANALYTICS_CODE']
  end
end

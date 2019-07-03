class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :analytics_code

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def route_not_found
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

private

  def analytics_code
    @analytics_code ||= ENV['GOOGLE_ANALYTICS_CODE']
  end

  def current_school
    current_user.school if current_user.try(:school_user?) || current_user.try(:school_admin?)
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :analytics_code
  helper_method :site_settings, :current_school_podium, :current_user_school

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def route_not_found
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  def site_settings
    @site_settings ||= SiteSettings.current
  end

  def current_school_podium
    if @school && @school.scoreboard
      @school_podium ||= Podium.create(school: @school, scoreboard: @school.scoreboard)
    end
  end

  def current_user_school
    if current_user && current_user.school
      current_user.school
    end
  end

  private

  def analytics_code
    @analytics_code ||= ENV['GOOGLE_ANALYTICS_CODE']
  end
end

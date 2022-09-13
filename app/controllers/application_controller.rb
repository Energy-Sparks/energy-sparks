class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  around_action :switch_locale
  before_action :authenticate_user!
  before_action :analytics_code
  before_action :pagy_locale
  helper_method :site_settings, :current_school_podium, :current_user_school

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def switch_locale(&action)
    locale = LocaleFinder.new(params, request).locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    if Rails.env.production?
      { host: I18n.locale == :cy ? ENV['WELSH_APPLICATION_HOST'] : ENV['APPLICATION_HOST'] }
    else
      super
    end
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

  def current_ip_address
    request.remote_ip
  end

  private

  def analytics_code
    @analytics_code ||= ENV['GOOGLE_ANALYTICS_CODE']
  end

  def pagy_locale
    @pagy_locale = I18n.locale.to_s
  end
end

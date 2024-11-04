class ApplicationController < ActionController::Base
  include DefaultUrlOptionsHelper
  around_action :switch_locale
  before_action :authenticate_user!
  before_action :analytics_code
  before_action :pagy_locale
  before_action :check_admin_mode
  helper_method :site_settings, :current_school_podium, :current_user_school, :current_user_school_group, :current_user_default_school_group, :current_school, :current_school_group
  before_action :update_trackable!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  def after_sign_in_path_for(user)
    subdomain = ApplicationController.helpers.subdomain_for(user.preferred_locale)
    root_url(subdomain: subdomain).chomp('/') + session.fetch(:user_return_to, '/')
  end

  def switch_locale(*_args, &action)
    locale = LocaleFinder.new(params, request).locale
    I18n.with_locale(locale, &action)
  end

  def route_not_found
    render 'errors/error', status: :not_found
  end

  def site_settings
    @site_settings ||= SiteSettings.current
  end

  def current_school
    @current_school ||= if @school&.persisted?
                          @school
                        elsif @tariff_holder&.school? && @tariff_holder&.persisted?
                          @tariff_holder
                        end
  end

  def current_school_group
    @current_school_group ||= if @school_group&.persisted?
                                @school_group
                              elsif @tariff_holder&.school_group? && @tariff_holder&.persisted?
                                @tariff_holder
                              end
  end

  def current_school_podium
    @current_school_podium ||= podium_for(current_school) if current_school&.scoreboard
  end

  def current_user_school
    @current_user_school ||= current_user&.school
  end

  def current_user_school_group
    @current_user_school_group ||= current_user&.school_group
  end

  def current_user_default_school_group
    @current_user_default_school_group ||= current_user&.default_school_group
  end

  def current_ip_address
    request.remote_ip
  end

  private

  def podium_for(school)
    Podium.create(school: school, scoreboard: school.scoreboard)
  end

  def check_admin_mode
    if admin_mode? && !current_user_admin? && !login_page?
      render 'home/maintenance', layout: false
    end
  end

  def admin_mode?
    ENV['ADMIN_MODE'] == 'true'
  end

  def current_user_admin?
    current_user.present? && current_user.admin?
  end

  def login_page?
    controller_name == 'sessions'
  end

  def analytics_code
    @analytics_code ||= ENV['GOOGLE_ANALYTICS_CODE']
  end

  def pagy_locale
    @pagy_locale = I18n.locale.to_s
  end

  # user has signed in via devise "remember me" functionality
  def update_trackable!
    if user_signed_in? && !session[:updated_tracked_fields]
      current_user.update_tracked_fields!(request)
      session[:updated_tracked_fields] = true
    end
  end
end

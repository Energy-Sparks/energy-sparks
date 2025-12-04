class ApplicationController < ActionController::Base
  include DefaultUrlOptionsHelper
  around_action :switch_locale
  before_action :authenticate_user!
  before_action :analytics_code
  before_action :pagy_locale
  before_action :check_admin_mode
  helper_method :site_settings, :current_school_podium, :current_user_school, :current_user_school_group,
                :current_user_default_school_group, :current_school, :current_school_group, :utm_params
  before_action :update_trackable!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end

  def after_sign_in_path_for(user)
    subdomain = ApplicationController.helpers.subdomain_for(user.preferred_locale)
    root_url(subdomain: subdomain).chomp('/') + session.fetch(:user_return_to, '/')
  end

  def switch_locale(*_args, &)
    locale = LocaleFinder.new(params, request).locale
    I18n.with_locale(locale, &)
  end

  def route_not_found
    render 'errors/show', status: :not_found
  end

  def site_settings
    @site_settings ||= SiteSettings.current
  end

  def current_school
    @current_school ||= @school if @school&.persisted?
  end

  def current_school_group
    @current_school_group ||= @school_group if @school_group&.persisted?
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

  def utm_params
    params.permit(:utm_source, :utm_medium, :utm_campaign).to_h.symbolize_keys
  end

  private

  def podium_for(school)
    Podium.create(school: school, scoreboard: school.scoreboard)
  end

  def check_admin_mode
    return unless admin_mode? && !current_user_admin? && !login_page?

    render 'home/maintenance', layout: false
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
    @analytics_code ||= ENV.fetch('GOOGLE_ANALYTICS_CODE', nil)
  end

  def pagy_locale
    Pagy::I18n.locale = I18n.locale.to_s
  end

  # user has signed in via devise "remember me" functionality
  def update_trackable!
    return unless user_signed_in? && !session[:updated_tracked_fields]

    current_user.update_tracked_fields!(request)
    session[:updated_tracked_fields] = true
  end

  def handle_head_request
    head :ok if request.head?
  end
end

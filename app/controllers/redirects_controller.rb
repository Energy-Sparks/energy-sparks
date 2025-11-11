class RedirectsController < ApplicationController
  layout 'dashboards'

  skip_before_action :authenticate_user!
  helper_method :school_redirect_path

  def school_page_redirect
    new_session and return if current_user.nil?

    if current_user.group_user? || (current_user.school_admin? && current_user.has_other_schools?)
      choose_school
    elsif current_user.admin?
      redirect_to school_redirect_path(School.data_enabled.sample, params[:path]),
                    notice: 'Notice for admin users: you have followed a shortlink and have been redirected to a random school'
    else
      redirect_to school_redirect_path(current_user_school, params[:path])
    end
  end

  private

  def new_session
    store_location_for(:user, request.path)
    redirect_to new_user_session_path, notice: I18n.t('users.index.redirect')
  end

  def choose_school
    @path = params[:path]
    @schools = current_user.group_user? ? current_user.school_group.schools : current_user.cluster_schools
    @schools = @schools.visible.by_name
    render :choose_school
  end

  def school_redirect_path(school, path = nil)
    case path
    when 'dashboard'
      school_path(school)
    when 'pupils'
      pupils_school_path(school)
    when 'calendar'
      calendar_path(school.calendar)
    when 'scoreboard'
      scoreboard_path(school.scoreboard)
    else
      "/schools/#{school.slug}/#{ActionController::Base.helpers.sanitize(path)}"
    end
  end
end

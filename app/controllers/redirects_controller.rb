class RedirectsController < ApplicationController
  skip_before_action :authenticate_user!

  helper_method :school_redirect_path

  def school_page_redirect
    unless current_user.present?
      store_location_for(:user, "/s/#{params[:path]}")
      redirect_to new_user_session_path, notice: I18n.t('users.index.redirect') and return
    end
    user_role = current_user.role.to_sym
    if user_role == :group_admin || (user_role == :school_admin && current_user.has_other_schools?)
      @path = params[:path]
      @schools = if current_user.group_admin?
                   current_user.school_group.schools.visible.by_name
                 else
                   current_user.cluster_schools.visible.by_name
                 end
      render :choose_school, layout: 'dashboards'
    else
      school = user_role == :admin ? School.data_enabled.sample : current_user.school
      redirect_to school_redirect_path(school, params[:path])
    end
  end

  private

  def school_redirect_path(school, path)
    case path
    when 'dashboard'
      school_path(school)
    when 'pupils'
      pupils_school_path(school)
    else
      "/schools/#{school.slug}/#{path}"
    end
  end
end

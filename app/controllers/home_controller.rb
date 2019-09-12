class HomeController < ApplicationController
  # **** ALL ACTIONS IN THIS CONTROLLER ARE PUBLIC! ****
  skip_before_action :authenticate_user!
  before_action :redirect_if_logged_in, only: :index

  def index
    # This renders using rails magic, the home layout template which
    # does not include the application container
    @active_schools = School.active.count
  end

  def for_teachers
  end

  def for_pupils
  end

  def contact
  end

  def enrol
  end

  def getting_started
  end

  def scoring
  end

  def privacy_policy
  end

  def help
    # assign page, remove any non-alphanumeric characters, allow underscores
    @help_page = params[:help_page].tr('^A-Za-z0-9_', '') if params[:help_page]
  end

private

  def redirect_if_logged_in
    if user_signed_in?
      if current_user.school
        redirect_to school_path(current_user.school)
      elsif current_user.school_onboarding?
        redirect_to onboarding_path(current_user.school_onboardings.last)
      elsif current_user.school_group && can?(:show, current_user.school_group)
        redirect_to school_group_path(current_user.school_group)
      else
        redirect_to schools_path
      end
    end
  end
end

class HomeController < ApplicationController
  # **** ALL ACTIONS IN THIS CONTROLLER ARE PUBLIC! ****
  skip_before_action :authenticate_user!
  before_action :redirect_if_logged_in

  def index
    @schools_enrolled = School.where(enrolled: true).count
    @schools_eligible = School.count
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

  def help
    # assign page, remove any non-alphanumeric characters, allow underscores
    @help_page = params[:help_page].tr('^A-Za-z0-9_', '') if params[:help_page]
  end

private

  def redirect_if_logged_in
    if user_signed_in?
      if current_user.school
        redirect_to school_path(current_user.school)
      else
        redirect_to schools_path
      end
    end
  end
end

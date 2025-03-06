class SessionsController < Devise::SessionsController
  before_action :load_school, only: :new

  private

  def load_school
    if params[:school].present?
      @school = School.find(params[:school])
    else
      @schools = SchoolCreator.school_list_for_login_form
    end
  end
end

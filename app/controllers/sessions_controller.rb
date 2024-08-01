class SessionsController < Devise::SessionsController
  before_action :load_school, only: :new

  private

  def load_school
    if params[:school].present?
      @school = School.find_by(slug: params[:school])
    else
      @schools = Rails.cache.fetch(:schools_for_login_form) do
        School.school_list_for_login_form
      end
    end
  end
end

class SessionsController < Devise::SessionsController
  before_action :load_school, only: :new


  private

  def load_school
    if params[:school].present?
      @school = School.find_by(slug: params[:school])
    end
    @schools = School.active.order(:name)
  end
end

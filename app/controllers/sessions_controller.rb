class SessionsController < Devise::SessionsController
  before_action :load_school, only: :new

  private

  def load_school
    @school = School.find_by(slug: params[:school]) if params[:school].present?
    @schools = School.visible.order(:name)
  end
end

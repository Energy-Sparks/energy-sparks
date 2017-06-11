class ReportsController < AdminController

  def index
  end

  def loading
    @schools = School.enrolled.order(:name)
  end
end
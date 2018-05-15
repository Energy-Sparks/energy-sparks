class Schools::CalendarsController < CalendarsController
    before_action :set_school
  def show
    @template = @school.calendar.template?
  end

  def new
  end

private
  def set_school
    @school = School.find(params[:school_id])
  end
end

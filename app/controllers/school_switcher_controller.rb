class SchoolSwitcherController < ApplicationController
  def create
    school = School.find(params[:school_id])
    current_user.update(school: school)
    redirect_to school_path(school), notice: "Switched to #{school.name}"
  end
end

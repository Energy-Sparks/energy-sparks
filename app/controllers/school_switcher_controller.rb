class SchoolSwitcherController < ApplicationController
  def create
    current_user.add_cluster_school(current_user.school)
    school = School.find(params[:school_id])
    current_user.update(school: school)
    redirect_to school_path(school) + params[:path].to_s, notice: "Switched to #{school.name}"
  end
end

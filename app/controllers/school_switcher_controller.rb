class SchoolSwitcherController < ApplicationController

  def create

    from_school = current_user.school
    to_school = School.find(params[:school_id])

    current_user.update(school: to_school)

    url = request.referer.gsub(from_school.slug, to_school.slug)

    redirect_to url, notice: "Switched to #{to_school.name}"

  end

end

# frozen_string_literal: true

class SchoolSwitcherController < ApplicationController
  def create
    current_user.add_cluster_school(current_user.school)
    school = School.find(params.expect(:school_id))
    current_user.update(school:)
    redirect_to school_path(school) + subpath, notice: "Switched to #{school.name}"
  end

  private

  def subpath = params[:path] ? "/#{params[:path]}" : ''
end

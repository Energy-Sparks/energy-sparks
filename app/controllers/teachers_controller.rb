class TeachersController < ApplicationController
  before_action :authorized?

private

  def authorized?
    unless current_user.admin? || current_user.staff?
      flash[:error] = "You are not authorized to view that page."
      redirect_to root_path
    end
  end
end

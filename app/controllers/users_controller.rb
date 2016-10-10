class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = User.all.includes(:school)
  end
end

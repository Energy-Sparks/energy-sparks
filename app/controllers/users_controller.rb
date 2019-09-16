class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = @users.all.includes(:school).order(:email)
  end

  def new
    set_schools_options
  end

  def edit
    set_schools_options
  end

  def create
    @user.confirmed_at = Time.zone.now
    if @user.save
      redirect_to users_path, notice: 'User was successfully created.'
    else
      set_schools_options
      render :new
    end
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: 'User was successfully updated.'
    else
      set_schools_options
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

private

  def user_params
    params[:user].delete(:password) if params[:user][:password].blank?
    params.require(:user).permit(:email, :password, :role, :school_id, :school_group_id)
  end

  def set_schools_options
    @schools = School.order(:name)
    @school_groups = SchoolGroup.order(:name)
  end
end

class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = @users.all.includes(:school).order(:email)
  end

  def show
  end

  def new
    set_schools_options
  end

  def edit
    set_schools_options
  end

  def create
    @user.confirmed_at = Time.zone.now
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        set_schools_options
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        set_schools_options
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

private

  def user_params
    params[:user].delete(:password) if params[:user][:password].blank?
    params.require(:user).permit(:email, :password, :role, :school_id)
  end

  def set_schools_options
    @schools = School.order(:name)
  end
end

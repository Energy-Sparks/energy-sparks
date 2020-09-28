module Admin
  class UsersController < AdminController
    load_and_authorize_resource

    def index
      @school_users = school_users
      @school_group_users = @users.where.not(school_group_id: nil).order('school_groups.name', :email).includes(:school_group)
      @unattached_users = @users.where(school_id: nil, school_group_id: nil).order(:email)
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
        redirect_to admin_users_path, notice: 'User was successfully created.'
      else
        set_schools_options
        render :new
      end
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: 'User was successfully updated.'
      else
        set_schools_options
        render :edit
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: 'User was successfully destroyed.'
    end

  private

    def user_params
      params[:user].delete(:password) if params[:user][:password].blank?
      params.require(:user).permit(:name, :email, :password, :role, :school_id, :school_group_id, :staff_role_id, cluster_school_ids: [])
    end

    def set_schools_options
      @schools = School.order(:name)
      @school_groups = SchoolGroup.order(:name)
    end

    def school_users
      users = {}
      SchoolGroup.all.order(:name).each do |school_group|
        users[school_group] = {}
        school_group.schools.order(:name).each do |school|
          users[school_group][school] = (school.users + school.cluster_users).uniq.sort_by(&:email)
        end
      end
      users
    end
  end
end

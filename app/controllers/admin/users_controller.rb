# frozen_string_literal: true

module Admin
  class UsersController < AdminController
    include ApplicationHelper
    load_and_authorize_resource

    def index
      @school_groups = SchoolGroup.all.by_name
      @search_users = find_users
      @unattached_users = @users.where(school_id: nil, school_group_id: nil).order(:email)
      respond_to do |format|
        format.html {}
        format.csv { send_data User.admin_user_export_csv, filename: 'users.csv' }
      end
    end

    def new
      set_schools_options
    end

    def edit
      set_schools_options
    end

    def create
      @user.created_by = current_user
      if @user.save
        redirect_to admin_users_path, notice: 'User was successfully created.'
      else
        set_schools_options
        render :new
      end
    end

    def update
      school_ids = -> { (@user.cluster_school_ids + [@user.school_id]).compact.uniq }
      before_school_ids = school_ids.call
      @user.assign_attributes(user_params)
      if @user.save(context: :form_update)
        if OnboardingMailer2025.enabled?
          (school_ids.call - before_school_ids).each do |school_id|
            school = School.find(school_id)
            next unless school.data_visible?

            OnboardingMailer2025.with(user: @user, school:, locale: @user.preferred_locale)
                                .welcome_existing.deliver_later
          end
        end
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

    def lock
      user = User.find(params['user_id'])
      user.lock_access!(send_instructions: false)
      redirect_back fallback_location: admin_users_path, notice: "User '#{user.email}' was successfully locked."
    end

    def unlock
      user = User.find(params['user_id'])
      user.unlock_access!
      redirect_back fallback_location: admin_users_path, notice: "User '#{user.email}' was successfully unlocked."
    end

    def disable
      user = User.find(params['user_id'])
      user.disable!
      redirect_back fallback_location: admin_users_path, notice: "User '#{user.email}' was successfully disabled."
    end

    def enable
      user = User.find(params['user_id'])
      user.enable!
      redirect_back fallback_location: admin_users_path, notice: "User '#{user.email}' was successfully activated."
    end

    def mailchimp_redirect
      user = User.find(params['user_id'])
      contact = Mailchimp::AudienceManager.new.get_list_member(user.email)
      if contact
        redirect_to "https://#{ENV.fetch('MAILCHIMP_SERVER')}.admin.mailchimp.com/audience/contact-profile?contact_id=#{contact.contact_id}"
      else
        redirect_back fallback_location: admin_users_path, notice: 'Cannot find user in Mailchimp'
      end
    end

    private

    def find_users
      if params[:search].present?
        search = params[:search]
        if search['email'].present?
          return User.where('email ILIKE ?', "%#{search['email']}%").where.not(role: :pupil).limit(50)
        end

        return []

      end
      []
    end

    def user_params
      params.require(:user)
            .permit(:name, :active, :email, :role, :school_id, :school_group_id, :staff_role_id, cluster_school_ids: [])
    end

    def set_schools_options
      @schools = School.order(:name)
      @school_groups = SchoolGroup.order(:name)
    end

    def school_users
      users = {}
      SchoolGroup.order(:name).each do |school_group|
        users[school_group] = {}
        school_group.schools.by_name.each do |school|
          users[school_group][school] = (school.users + school.cluster_users).uniq.sort_by(&:email)
        end
      end
      users
    end
  end
end

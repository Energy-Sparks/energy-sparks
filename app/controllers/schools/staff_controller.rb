module Schools
  class StaffController < ApplicationController
    include AlertContactCreator
    include NewsletterSubscriber

    load_and_authorize_resource :school

    def new
      authorize! :manage_users, @school
      @staff = @school.users.staff.new
      authorize! :create, @staff
    end

    def create
      @staff = User.new_staff(@school, staff_params)
      if @staff.save
        create_alert_contact(@school, @staff) if auto_create_alert_contact?
        subscribe_newsletter(@school, @staff) if auto_subscribe_newsletter?
        redirect_to school_users_path(@school)
      else
        render :new
      end
    end

    def edit
      @staff = @school.users.staff.find(params[:id])
      authorize! :edit, @staff
    end

    def update
      @staff = @school.users.staff.find(params[:id])
      authorize! :update, @staff
      if @staff.update(staff_params)
        redirect_to school_users_path(@school)
      else
        render :edit
      end
    end

    private

    def staff_params
      params.require(:user).permit(:name, :email, :staff_role_id)
    end
  end
end

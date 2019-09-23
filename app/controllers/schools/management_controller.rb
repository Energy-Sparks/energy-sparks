module Schools
  class ManagementController < ApplicationController
    include AlertContactCreator

    load_and_authorize_resource :school

    def new
      authorize! :manage_users, @school
      @management = @school.users.management.new
      authorize! :create, @management
    end

    def create
      @management = User.new_management(@school, management_params)
      if @management.save
        create_alert_contact(@school, @management) if auto_create_alert_contact?
        redirect_to school_users_path(@school)
      else
        render :new
      end
    end

    def edit
      @management = @school.users.management.find(params[:id])
      authorize! :edit, @management
    end

    def update
      @management = @school.users.management.find(params[:id])
      authorize! :update, @management
      if @management.update(management_params)
        redirect_to school_users_path(@school)
      else
        render :edit
      end
    end

    private

    def management_params
      params.require(:user).permit(:name, :email, :staff_role_id)
    end
  end
end

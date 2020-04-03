module Admin
  class TeamMembersController < AdminController
    load_and_authorize_resource

    def index
      @staff = TeamMember.staff.order(:position)
      @consultants = TeamMember.consultant.order(:position)
      @trustees = TeamMember.trustee.order(:position)
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @team_member.save
        redirect_to admin_team_members_path, notice: 'Team member was successfully created.'
      else
        render :new
      end
    end

    def update
      if @team_member.update(team_member_params)
        redirect_to admin_team_members_path, notice: 'Team member was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @team_member.destroy
      redirect_to admin_team_members_path, notice: 'Team member was successfully destroyed.'
    end

    private

    def team_member_params
      params.require(:team_member).permit(:title, :description, :position, :image, :role, :profile)
    end
  end
end

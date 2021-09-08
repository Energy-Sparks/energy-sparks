module Admin
  class InterventionTypeGroupsController < AdminController
    load_and_authorize_resource

    def index
      @intervention_type_groups = @intervention_type_groups.by_title
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @intervention_type_group.save
        redirect_to admin_intervention_type_groups_path, notice: 'Intervention category was successfully created.'
      else
        render :new
      end
    end

    def update
      if @intervention_type_group.update(intervention_type_group_params)
        redirect_to admin_intervention_type_groups_path, notice: 'Intervention category was successfully updated.'
      else
        render :edit
      end
    end

  private

    def intervention_type_group_params
      params.require(:intervention_type_group).permit(:title, :description, :image, :active, :icon)
    end
  end
end

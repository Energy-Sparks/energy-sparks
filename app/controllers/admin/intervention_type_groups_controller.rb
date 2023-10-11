module Admin
  class InterventionTypeGroupsController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    def index
      @intervention_type_groups = @intervention_type_groups.by_name
    end

    def show; end

    def new; end

    def edit; end

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
      translated_params = t_params(InterventionTypeGroup.mobility_attributes)
      params.require(:intervention_type_group).permit(translated_params, :name, :description, :active, :icon)
    end
  end
end

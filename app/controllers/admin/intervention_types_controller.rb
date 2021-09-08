module Admin
  class InterventionTypesController < AdminController
    load_and_authorize_resource

    def index
      @intervention_types = @intervention_types.includes(:intervention_type_group).order("intervention_types.title", :title)
    end

    def show
      #      @recorded = Intervention.where(activity_type: @activity_type).count
      #      @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
    end

    def new
    end

    def edit
    end

    def create
      if @intervention_type.save
        redirect_to admin_intervention_types_path, notice: 'Intervention type was successfully created.'
      else
        render :new
      end
    end

    def update
      if @intervention_type.update(intervention_type_params)
        redirect_to admin_intervention_types_path, notice: 'Intervention type was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      # Intervention types should be marked inactive rather than deleted
      # this method does NOT delete the Intervention type
      redirect_to admin_intervention_types_path, notice: 'Intervention type not deleted, please mark as inactive'
    end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_type_params
      params.require(:intervention_type).permit(:title,
          :summary,
          :description,
          :download_links,
          :image,
          :active,
          :intervention_type_group_id,
          :points)
    end
  end
end

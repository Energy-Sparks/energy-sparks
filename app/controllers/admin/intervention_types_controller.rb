module Admin
  class InterventionTypesController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    def index
      @intervention_types = @intervention_types.includes(:intervention_type_group).order('intervention_types.name', :name)
    end

    def new
      add_intervention_type_suggestions
      3.times do
        @intervention_type.link_rewrites.build
      end
    end

    def edit
      number_of_suggestions_so_far = @intervention_type.intervention_type_suggestions.count
      if number_of_suggestions_so_far > 8
        @intervention_type.intervention_type_suggestions.build
      else
        # Top up to 8
        add_intervention_type_suggestions(number_of_suggestions_so_far)
      end
      3.times do
        @intervention_type.link_rewrites.build
      end
    end

    def create
      if @intervention_type.save
        redirect_to admin_intervention_types_path, notice: 'Intervention type was successfully created.'
      else
        add_intervention_type_suggestions
        render :new
      end
    end

    def update
      if @intervention_type.update(intervention_type_params)
        # Rewrite links in Welsh text
        rewritten = @intervention_type.update(@intervention_type.rewrite_all)
        notice = rewritten ? 'Intervention type was successfully updated.' : 'Intervention type was saved, but failed to rewrite links.'
        redirect_to admin_intervention_types_path, notice: notice
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

    def add_intervention_type_suggestions(number_of_suggestions_so_far = 0)
      (0..(7 - number_of_suggestions_so_far)).each { @intervention_type.intervention_type_suggestions.build }
    end

    def intervention_type_params
      translated_params = t_params(InterventionType.mobility_attributes + InterventionType.t_attached_attributes)
      params.require(:intervention_type).permit(translated_params,
                                                :name,
                                                :summary,
                                                :description,
                                                :download_links,
                                                :active,
                                                :intervention_type_group_id,
                                                :score,
                                                :custom,
                                                :show_on_charts,
                                                fuel_type: [],
                                                link_rewrites_attributes: link_rewrites_params,
                                                intervention_type_suggestions_attributes: suggestions_params)
    end

    def suggestions_params
      %i[id suggested_type_id _destroy]
    end

    def link_rewrites_params
      %i[id source target _destroy]
    end
  end
end

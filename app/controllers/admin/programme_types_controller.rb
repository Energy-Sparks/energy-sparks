module Admin
  class ProgrammeTypesController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    def index
      @programme_types = @programme_types.by_title
    end

    def show
    end

    def edit
    end

    def create
      if @programme_type.save
        redirect_to admin_programme_types_path, notice: 'Programme type created'
      else
        render :new
      end
    end

    def update
      if @programme_type.update(programme_type_params)
        redirect_to admin_programme_types_path, notice: 'Programme type updated'
      else
        render :edit
      end
    end

    def destroy
      @programme_type.destroy
      redirect_to admin_programme_types_path, notice: "Programme type was successfully deleted."
    end

  private

    def programme_type_params
      translated_params = t_params(ProgrammeType.mobility_attributes)
      params.require(:programme_type).permit(translated_params, :title, :description, :short_description, :document_link, :active, :default, :image)
    end
  end
end

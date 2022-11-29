module Admin
  class ActivityCategoriesController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    def index
      @activity_categories = @activity_categories.by_name
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @activity_category.save
        redirect_to admin_activity_categories_path, notice: 'Activity category was successfully created.'
      else
        render :new
      end
    end

    def update
      if @activity_category.update(activity_category_params)
        redirect_to admin_activity_categories_path, notice: 'Activity category was successfully updated.'
      else
        render :edit
      end
    end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_category_params
      translated_params = t_params(ActivityCategory.mobility_attributes + ActivityCategory.t_attached_attributes)
      params.require(:activity_category).permit(translated_params, :name, :description, :featured, :pupil, :live_data)
    end
  end
end

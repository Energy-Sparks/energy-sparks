module Admin
  class ActivityCategoriesController < AdminController
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
      params.require(:activity_category).permit(:name, :description, :image, :featured, :pupil)
    end
  end
end

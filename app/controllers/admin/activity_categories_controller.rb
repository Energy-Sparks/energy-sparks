module Admin
  class ActivityCategoriesController < AdminController
    load_and_authorize_resource

    # GET /activity_categories
    def index
    end

    # GET /activity_categories/1
    def show
    end

    # GET /activity_categories/new
    def new
    end

    # GET /activity_categories/1/edit
    def edit
    end

    # POST /activity_categories
    def create
      if @activity_category.save
        redirect_to admin_activity_categories_path, notice: 'Activity category was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /activity_categories/1
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
      params.require(:activity_category).permit(:name, :description)
    end
  end
end

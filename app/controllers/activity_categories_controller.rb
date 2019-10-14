class ActivityCategoriesController < ApplicationController
  include ActivityTypeFilterable

  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:index]

  # GET /activity_categories
  def index
    @filter = activity_type_filter
    @activity_categories = @activity_categories.order(:name)
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
      redirect_to @activity_category, notice: 'Activity category was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /activity_categories/1
  def update
    if @activity_category.update(activity_category_params)
      redirect_to @activity_category, notice: 'Activity category was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /activity_categories/1
  def destroy
    # activity categories should be marked inactive rather than deleted
    # this method does NOT delete the activity category
    # @activity_category.destroy
    redirect_to activity_categories_url, notice: 'Activity category not deleted'
  end

private

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_category_params
    params.require(:activity_category).permit(:name, :description)
  end
end

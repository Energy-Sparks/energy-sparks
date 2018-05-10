class ActivityCategoriesController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:index]
  before_action :set_activity_category, only: [:show, :edit, :update, :destroy]

  # GET /activity_categories
  # GET /activity_categories.json
  def index
    @key_stage_tags = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: { context: 'key_stages' }).order(:name).to_a
    @activity_categories = ActivityCategory.all.order(:name)
  end

  # GET /activity_categories/1
  # GET /activity_categories/1.json
  def show
  end

  # GET /activity_categories/new
  def new
    @activity_category = ActivityCategory.new
  end

  # GET /activity_categories/1/edit
  def edit
  end

  # POST /activity_categories
  # POST /activity_categories.json
  def create
    @activity_category = ActivityCategory.new(activity_category_params)

    respond_to do |format|
      if @activity_category.save
        format.html { redirect_to @activity_category, notice: 'Activity category was successfully created.' }
        format.json { render :show, status: :created, location: @activity_category }
      else
        format.html { render :new }
        format.json { render json: @activity_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activity_categories/1
  # PATCH/PUT /activity_categories/1.json
  def update
    respond_to do |format|
      if @activity_category.update(activity_category_params)
        format.html { redirect_to @activity_category, notice: 'Activity category was successfully updated.' }
        format.json { render :show, status: :ok, location: @activity_category }
      else
        format.html { render :edit }
        format.json { render json: @activity_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activity_categories/1
  # DELETE /activity_categories/1.json
  def destroy
    # activity categories should be marked inactive rather than deleted
    # this method does NOT delete the activity category
    # @activity_category.destroy
    respond_to do |format|
      format.html { redirect_to activity_categories_url, notice: 'Activity category not deleted' }
      format.json { head :no_content }
    end
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_activity_category
    @activity_category = ActivityCategory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_category_params
    params.require(:activity_category).permit(:name, :description, :badge_name)
  end

  def activity_category_filter_params
  end
end

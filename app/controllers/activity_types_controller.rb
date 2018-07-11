class ActivityTypesController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:show]
  before_action :set_activity_type, only: [:show, :edit, :update, :destroy]

  # GET /activity_types
  # GET /activity_types.json
  def index
    @activity_types = ActivityType.all.includes(:activity_category).order("activity_categories.name", :name)
  end

  # GET /activity_types/1
  # GET /activity_types/1.json
  def show
    @recorded = Activity.where(activity_type: @activity_type).count
    @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
  end

  # GET /activity_types/new
  def new
    @key_stage_tags = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: { context: 'key_stages' }).order(:name).to_a
    @activity_type = ActivityType.new
    add_activity_type_suggestions
  end

  # GET /activity_types/1/edit
  def edit
    @key_stage_tags = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: { context: 'key_stages' }).order(:name).to_a

    number_of_suggestions_so_far = @activity_type.activity_type_suggestions.count
    if number_of_suggestions_so_far > 8
      @activity_type.activity_type_suggestions.build
    else
      # Top up to 8
      add_activity_type_suggestions(number_of_suggestions_so_far)
    end
  end

  # POST /activity_types
  # POST /activity_types.json
  def create
    @activity_type = ActivityType.new(activity_type_params)

    respond_to do |format|
      if @activity_type.save
        format.html { redirect_to @activity_type, notice: 'Activity type was successfully created.' }
        format.json { render :show, status: :created, location: @activity_type }
      else
        format.html do
          @key_stage_tags = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: { context: 'key_stages' }).order(:name).to_a
          add_activity_type_suggestions
          render :new
        end
        format.json { render json: @activity_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activity_types/1
  # PATCH/PUT /activity_types/1.json
  def update
    respond_to do |format|
      if @activity_type.update(activity_type_params)
        format.html { redirect_to @activity_type, notice: 'Activity type was successfully updated.' }
        format.json { render :show, status: :ok, location: @activity_type }
      else
        format.html { render :edit }
        format.json { render json: @activity_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activity_types/1
  # DELETE /activity_types/1.json
  def destroy
    # activity types should be marked inactive rather than deleted
    # this method does NOT delete the activity type
    # @activity_type.destroy
    respond_to do |format|
      format.html { redirect_to activity_types_url, notice: 'Activity type not deleted, please mark as inactive' }
      format.json { head :no_content }
    end
  end

private

  def add_activity_type_suggestions(number_of_suggestions_so_far = 0)
    (0..(7 - number_of_suggestions_so_far)).each { @activity_type.activity_type_suggestions.build }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_activity_type
    @activity_type = ActivityType.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_type_params
    params.require(:activity_type).permit(:name,
        :description,
        :active,
        :activity_category_id,
        :score,
        :badge_name,
        :repeatable,
        :data_driven,
        key_stage_ids: [],
        activity_type_suggestions_attributes: suggestions_params)
  end

  def suggestions_params
    [:id, :suggested_type_id, :_destroy]
  end
end

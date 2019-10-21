class ActivitiesController < ApplicationController
  load_resource :school
  load_and_authorize_resource through: :school

  skip_before_action :authenticate_user!, only: [:index, :show]

  # GET /activities
  # GET /activities.json
  def index
    @activities = @activities.order(happened_on: :desc)
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
    @activity_type_content = TemplateInterpolation.new(
      @activity.activity_type,
      render_with: SchoolTemplate.new(@school)
    ).interpolate(
      :school_specific_description_or_fallback
    )
  end

  # GET /activities/new
  def new
    if params[:activity_type_id].present?
      activity_type = ActivityType.find(params[:activity_type_id])
      if activity_type.present?
        @activity.activity_type = activity_type
        @activity.activity_category = activity_type.activity_category
      end
    end
  end

  # GET /activities/1/edit
  def edit
  end

  # POST /activities
  # POST /activities.json
  def create
    respond_to do |format|
      if ActivityCreator.new(@activity).process
        format.html { redirect_to school_activity_path(@school, @activity), notice: 'Activity was successfully created.' }
        format.json { render :show, status: :created, location: @school }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  def update
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to school_activity_path(@school, @activity), notice: 'Activity was successfully updated.' }
        format.json { render :show, status: :ok, location: @school }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    @activity.observations.each {|observation| ObservationRemoval.new(observation).process}
    @activity.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: school_activities_path(@school), notice: 'Activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

private

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    params.require(:activity).permit(:school_id, :activity_type_id, :title, :description, :happened_on, :content)
  end
end

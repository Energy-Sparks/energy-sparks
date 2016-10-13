class ActivitiesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  # GET /activities
  # GET /activities.json
  def index
    set_school
    @activities = @school.activities.order(happened_on: :desc)
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
  end

  # GET /activities/new
  def new
    set_school
    @activity = @school.activities.new
    authorize! :new, @activity
  end

  # GET /activities/1/edit
  def edit
    authorize! :edit, @activity
  end

  # POST /activities
  # POST /activities.json
  def create
    set_school
    @activity = @school.activities.new(activity_params)
    authorize! :create, @activity
    respond_to do |format|
      if @activity.save
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
    authorize! :update, @activity
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
    authorize! :destroy, @activity
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to school_activity_path(@school, @activity), notice: 'Activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    set_school
    @activity = @school.activities.find(params[:id])
  end

  def set_school
    @school = School.find(params[:school_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    params.require(:activity).permit(:school_id, :activity_type_id, :title, :description, :happened_on)
  end
end

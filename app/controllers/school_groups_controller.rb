class SchoolGroupsController < ApplicationController
  load_and_authorize_resource
  before_action :set_school_group, only: [:show, :edit, :update, :destroy]

  # GET /school_groups
  def index
    @school_groups = SchoolGroup.order(:name)
  end

  # GET /school_groups/new
  def new
    @school_group = SchoolGroup.new
  end

  # GET /school_groups/1/edit
  def edit
    @schools = @school_group.schools.order(:name)
  end

  # POST /school_groups
  def create
    @school_group = SchoolGroup.new(school_group_params)
    if @school_group.save
      redirect_to school_groups_path, notice: 'School group was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /school_groups/1
  def update
    if @school_group.update(school_group_params)
      redirect_to school_groups_path, notice: 'School group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /school_groups/1
  def destroy
    @school_group.safe_destroy
    redirect_to school_groups_url, notice: 'School group deleted'
  rescue EnergySparks::SafeDestroyError => error
    redirect_to school_groups_url, alert: "Delete failed: #{error.message}"
  end

private

  def set_school_group
    @school_group = SchoolGroup.friendly.find(params[:id])
  end

  def school_group_params
    params.require(:school_group).permit(
      :name, :description, :scoreboard_id,
      :default_calendar_area_id,
      :default_weather_underground_area_id,
      :default_solar_pv_tuos_area_id
    )
  end
end

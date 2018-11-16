class SchoolsController < ApplicationController
  include KeyStageFilterable

  load_and_authorize_resource find_by: :slug
  skip_before_action :authenticate_user!, only: [:index, :show, :usage, :awards]
  before_action :set_school, only: [:show, :edit, :update, :destroy, :usage, :awards, :suggest_activity, :data_explorer]
  before_action :set_key_stage_tags, only: [:new, :create, :edit, :update]

  # GET /schools
  # GET /schools.json
  def index
    @scoreboards = Scoreboard.includes(:schools).where.not(schools: { id: nil }).order(:name)
    @ungrouped_enrolled_schools = School.enrolled.without_group.order(:name)
    @schools_not_enrolled = School.not_enrolled.order(:name)
  end

  # GET /schools/1
  # GET /schools/1.json
  def show
    redirect_to enrol_path unless @school.enrolled? || (current_user && current_user.manages_school?(@school.id))
    @activities = @school.activities.order("happened_on DESC")
    @meters = @school.meters.order(:meter_no)
    @badges = @school.badges_by_date(limit: 6)
  end

  # GET /schools/:id/awards
  def awards
    @all_badges = Merit::Badge.all.to_a.sort
    @badges = @school.badges_by_date(order: :asc)
  end

  def suggest_activity
    @key_stage_filter_names = work_out_which_filters_to_set
    @key_stage_tags = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: { context: 'key_stages' }).order(:name).to_a
    @first = @school.activities.empty?
    @suggestions = NextActivitySuggesterWithKeyStages.new(@school, @key_stage_filter_names).suggest
  end

  # GET /schools/new
  def new
    @school = School.new
  end

  # GET /schools/1/edit
  def edit
  end

  # POST /schools
  # POST /schools.json
  def create
    @school = School.new(school_params)

    respond_to do |format|
      if @school.save
        format.html { redirect_to @school, notice: 'School was successfully created.' }
        format.json { render :show, status: :created, location: @school }
      else
        format.html { render :new }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /schools/1
  # PATCH/PUT /schools/1.json
  def update
    respond_to do |format|
      if @school.update(school_params)
        format.html { redirect_to @school, notice: 'School was successfully updated.' }
        format.json { render :show, status: :ok, location: @school }
      else
        format.html { render :edit }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schools/1
  # DELETE /schools/1.json
  def destroy
    @school.destroy
    respond_to do |format|
      format.html { redirect_to schools_url, notice: 'School was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /schools/:id/usage
  def usage
    set_supply
    set_first_date
    set_to_date
    render "#{period}_usage"
  end

private

  def set_key_stage_tags
    @key_stage_tags = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: { context: 'key_stages' }).order(:name).to_a
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_school
    @school = School.find(params[:id])
  end

  def school_params
    params.require(:school).permit(
      :name,
      :school_type,
      :address,
      :postcode,
      :website,
      :enrolled,
      :school_group_id,
      :calendar_area_id,
      :weather_underground_area_id,
      :solar_pv_tuos_area_id,
      :urn,
      :gas_dataset,
      :electricity_dataset,
      :competition_role,
      :number_of_pupils,
      :floor_area,
      key_stage_ids: [],
      school_times_attributes: school_time_params
    )
  end

  def school_time_params
    [:id, :day, :opening_time, :closing_time]
  end

  def meter_params
    [:id, :meter_no, :meter_type, :active, :name]
  end

  def set_supply
    @supply = params[:supply].present? ? params[:supply] : "electricity"
  end

  def period
    params[:period]
  end

  def set_first_date
    if period == "hourly"
      begin
        @first_date = Date.parse params[:first_date]
      rescue
        @first_date = get_last_reading_date_with_readings #@school.last_reading_date(@supply)
      end
    else
      begin
        @first_date = Date.parse params[:first_date]
      rescue
        @first_date = get_last_reading_date_with_readings #@school.last_reading_date(@supply)
      end
      #ensure we're looking at beginning of the week
      @first_date = @first_date.beginning_of_week(:sunday) if @first_date.present?
    end
  end

  def set_to_date
    if period == "hourly"
      begin
        @to_date = Date.parse params[:to_date]
      rescue
        @to_date = nil
      end
    else
      begin
        @to_date = Date.parse params[:to_date]
      rescue
        last_reading = @school.last_reading_date(@supply)
        @to_date = last_reading - 7.days if last_reading.present?
      end
      #ensure we're looking at beginning of the week
      @to_date = @to_date.beginning_of_week(:sunday) if @to_date.present?
    end
  end

  # TODO this is all to do with the half hour thing
  def get_last_reading_date_with_readings
    first_go = @school.last_reading_date(@supply)
    if first_go && @school.meter_readings.where(read_at: first_go.all_day).where(conditional_supply(@supply)).count < 48
      @school.last_reading_date(@supply, first_go - 1.day)
    else
      first_go
    end
  end

  def conditional_supply(supply)
    { meters: { meter_type: Meter.meter_types[supply] } } if supply
  end
end

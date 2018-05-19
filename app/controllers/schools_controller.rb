class SchoolsController < ApplicationController
  include KeyStageFilterable

  load_and_authorize_resource find_by: :slug
  skip_before_action :authenticate_user!, only: [:index, :show, :usage, :awards, :scoreboard]
  before_action :set_school, only: [:show, :edit, :update, :destroy, :usage, :awards, :suggest_activity, :data_explorer]
  before_action :set_key_stage_tags, only: [:new, :edit]

  # GET /schools
  # GET /schools.json
  def index
    @schools_enrolled = School.where(enrolled: true).order(:name)
    @schools_not_enrolled = School.where(enrolled: false).order(:name)
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
    @all_badges = Merit::Badge.all.to_a.sort { |a, b| a <=> b }
    @badges = @school.badges_by_date(order: :asc)
  end

  def suggest_activity
    @key_stage_filter_names = work_out_which_filters_to_set
    @key_stage_tags = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: { context: 'key_stages' }).order(:name).to_a
    @first = @school.activities.empty?
    @suggestions = NextActivitySuggesterWithKeyStages.new(@school, @key_stage_filter_names).suggest
  end

  # GET /schools/scoreboard
  def scoreboard
    #Added so merit can access the current user. Seems to require a variable with same name
    #as controller
    @school = current_user

    @schools = School.scoreboard
  end

  # GET /schools/new
  def new
    @school = School.new
    @school.meters.build
  end

  # GET /schools/1/edit
  def edit
    @school.meters.build
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
      :calendar_area_id,
      :urn,
      :gas_dataset,
      :electricity_dataset,
      :competition_role,
      key_stage_ids: [],
      meters_attributes: meter_params
    )
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
        @first_date = @school.last_reading_date(@supply)
      end
    else
      begin
        @first_date = Date.parse params[:first_date]
      rescue
        @first_date = @school.last_reading_date(@supply)
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
end

class SchoolsController < ApplicationController
  load_and_authorize_resource find_by: :slug
  skip_before_action :authenticate_user!, only: [:index, :show, :usage]
  before_action :set_school, only: [:show, :edit, :update, :destroy, :usage, :achievements]

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
    @activities = @school.activities.order(:happened_on).includes(:activity_type)
    @meters = @school.meters.order(:meter_no)
    @badges = @school.badges_by_date(limit: 6)
  end

  # GET /schools/:id/badges
  def achievements
    @badges = @school.badges_by_date(order: :asc)
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
        create_calendar
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
    set_to_date
    render "#{params[:period]}_usage"
  end

private

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
      :eco_school_status,
      :website,
      :enrolled,
      :urn,
      meters_attributes: meter_params
    )
  end

  def meter_params
    [:id, :meter_no, :meter_type, :active]
  end

  def set_to_date(default = Date.current - 1.day)
    begin
      @to_date = Date.parse params[:to_date]
    rescue
      @to_date = default
    end
  end

  def create_calendar
    new_calendar = Calendar.create_calendar_from_default("#{@school.name} Calendar")
    @school.update_attribute(:calendar_id, new_calendar.id)
  end
end

class SchoolsController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_school, only: [:show, :edit, :update, :destroy]

  # GET /schools
  # GET /schools.json
  def index
    @schools = School.order(:name)
  end

  # GET /schools/1
  # GET /schools/1.json
  def show
    @activities = @school.activities.order(:happened_on).includes(:activity_type)
    @meters = @school.meters.order(:meter_no)
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
    case params[:period]
    when 'daily'
      set_to_date
      return render 'daily_usage'
    end
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
end

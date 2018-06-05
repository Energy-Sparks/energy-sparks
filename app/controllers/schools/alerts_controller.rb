class Schools::AlertsController < ApplicationController

  load_and_authorize_resource find_by: :slug
  skip_before_action :authenticate_user!
  before_action :set_school
 
  def index
    @alerts = @school.alerts
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


private



  # Use callbacks to share common setup or constraints between actions.
  def set_school
    @school = School.find(params[:school_id])
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
      :weather_underground_area_id,
      :solar_pv_tuos_area_id,
      :urn,
      :gas_dataset,
      :electricity_dataset,
      :competition_role,
      :number_of_pupils,
      :floor_area,
      key_stage_ids: [],
      meters_attributes: meter_params,
      school_times_attributes: school_time_params
    )
  end

  def school_time_params
    [:id, :day, :opening_time, :closing_time]
  end

  def meter_params
    [:id, :meter_no, :meter_type, :active, :name]
  end

end

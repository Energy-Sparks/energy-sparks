module Schools
  class TransportSurveysController < ApplicationController
    load_resource :school

    # Need to authorize transport_survey
    # load_and_authorize_resource :transport_survey, through: :school

    skip_before_action :authenticate_user!, only: [:index, :show]

    # We might be best to use edit / update for specifically editing and updating later down the line but it makes sense to put it here for now.
    # GET /schools/transport_surveys/2022-03-11/edit
    # We need to decide how we are going to lock this down. For example, we shouldn't allow surveying in the future (or the past really). Maybe Just today?
    # The plan is here to eventually load the offline form with this action
    def edit
      @transport_survey = @school.transport_surveys.find_or_initialize_by(run_on: params[:run_on])
      render layout: false
    end

    # PATCH/PUT /schools/transport_surveys/2022-03-11 or /schools/transport_surveys/2022-03-11.json
    # Take bunch of transport survey responses and write them to the database & create transport survey entry if not already been created
    def update
      Rails.logger.info "***************" + transport_survey_params.inspect

      @transport_survey = @school.transport_surveys.find_or_create_by!(run_on: transport_survey_params[:run_on])
      respond_to do |format|
        if @transport_survey.update(transport_survey_params)
          format.html { redirect_to school_transport_survey_url(@school, @transport_survey), notice: "Your responses have been saved!" }
          format.json { render :show, status: :created, location: @transport_survey }
        else
          format.html { render :edit, status: :unprocessable_entity, notice: "Something went wrong!" }
          format.json { render json: @transport_survey.errors, status: :unprocessable_entity }
        end
      end
    end

    # GET /schools/transport_surveys/1 or /schools/transport_surveys/1.json
    # show the responses so far
    def show
      @transport_survey = @school.transport_surveys.find_by(run_on: params[:run_on])
    end

    # GET /schools/transport_surveys or /schools/transport_surveys.json
    def index
      @transport_surveys = @school.transport_surveys.all
    end


    # DELETE /schools/transport_surveys/2022-03-11 or /schools/transport_surveys/2022-03-11.json
    def destroy
      @transport_survey = @school.transport_surveys.find_by(run_on: params[:run_on])
      @transport_survey.destroy
      respond_to do |format|
        format.html { redirect_to schools_transport_surveys_url, notice: "Transport survey was successfully destroyed." }
        format.json { head :no_content }
      end
    end

    private

    def transport_survey_params
      # might need to make this stricter at some point
      params.require(:transport_survey).permit(:run_on, responses: [:run_identifier, :journey_minutes, :surveyed_at, :passengers, :transport_type_id, :weather])
    end
  end
end

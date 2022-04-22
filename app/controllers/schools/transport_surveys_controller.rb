module Schools
  class TransportSurveysController < ApplicationController
    skip_before_action :authenticate_user!, only: [:index, :show]

    load_resource :school
    load_resource :transport_survey, find_by: :run_on, id_param: :run_on, through: :school, except: [:edit, :update]

    authorize_resource :transport_survey
    before_action :load_or_create, only: [:update]

    # We might be best to use edit / update for specifically editing and updating later down the line but it makes sense to put it here for now.
    # We need to decide how we are going to lock this down. For example, we shouldn't allow surveying in the future (or the past really). Maybe Just today?
    # The plan is here to eventually load the offline form with this action
    def edit
      @transport_survey = @school.transport_surveys.find_or_initialize_by(run_on: params[:run_on])
      # authorize! :read, @transport_survey
    end

    # Take bunch of transport survey responses and write them to the database & create transport survey entry if not already been created
    # The load_or_create is an attempt to make this more robust - if someone has since come along and deleted the survey entry,
    # we need the responses to still be written back to the db, so we need to create the transport survey entry if it's not there? Maybe
    def update
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

    def destroy
      @transport_survey.destroy
      redirect_to school_transport_surveys_url(@school), notice: "Transport survey was successfully destroyed."
    end

    private

    def transport_survey_params
      params.require(:transport_survey).permit(:run_on, responses: [:run_identifier, :journey_minutes, :surveyed_at, :passengers, :transport_type_id, :weather])
    end

    def load_or_create
      @transport_survey = @school.transport_surveys.find_or_create_by!(run_on: transport_survey_params[:run_on])
    end
  end
end

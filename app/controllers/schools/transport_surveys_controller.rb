module Schools
  class TransportSurveysController < ApplicationController
    skip_before_action :authenticate_user!, only: [:index, :show]

    load_resource :school
    load_resource :transport_survey, find_by: :run_on, id_param: :run_on, through: :school, except: [:edit, :update]

    authorize_resource :transport_survey
    before_action :load_or_create, only: [:update]

    def start
      @transport_survey = @school.transport_surveys.find_or_initialize_by(run_on: Time.zone.today)
      render :edit
    end

    # We need to decide how we are going to lock this down. For example, we shouldn't allow surveying in the future (or the past really). Maybe Just today?
    def edit
      @transport_survey = @school.transport_surveys.find_or_initialize_by(run_on: params[:run_on])
      # authorize! :read, @transport_survey
    end

    def update
      if @transport_survey.update(transport_survey_params)
        render json: @transport_survey, status: :ok
      else
        render json: @transport_survey.errors, status: :unprocessable_entity
      end
    end

    def show
      respond_to do |format|
        format.html
        format.json { render json: @transport_survey.pie_chart_data }
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

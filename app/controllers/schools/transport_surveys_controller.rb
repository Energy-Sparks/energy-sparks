module Schools
  class TransportSurveysController < ApplicationController
    include Pagy::Method
    skip_before_action :authenticate_user!, only: [:index, :show]

    load_and_authorize_resource :school
    load_and_authorize_resource :transport_survey, find_by: :run_on, id_param: :run_on, through: :school, except: [:start, :update]
    before_action :set_breadcrumbs

    def index
      @transport_surveys = @transport_surveys.order(run_on: :desc)
      @pagy, @transport_surveys = pagy(@transport_surveys)
    end

    def start
      @transport_survey = @school.transport_surveys.find_or_initialize_by(run_on: Time.zone.today)
      authorize! :start, @transport_survey

      render :edit
    end

    def edit
      redirect_to school_transport_survey_responses_url(@school, @transport_survey)
    end

    def update
      @transport_survey = @school.transport_surveys.find_or_initialize_by(
        run_on: transport_survey_params[:run_on]
      )
      authorize! :start, @transport_survey
      # TransportSurvey#reponses= requires a persisted record
      @transport_survey.save! unless @transport_survey.persisted?

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
      authorize! :delete, @transport_survey

      @transport_survey.destroy
      redirect_to school_transport_surveys_url(@school), notice: t('schools.transport_surveys.destroy.notice')
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [
        { name: I18n.t('activerecord.models.transport_survey.other') },
      ]
    end

    def transport_survey_params
      params.require(:transport_survey).permit(:run_on, responses: [:run_identifier, :journey_minutes, :surveyed_at, :passengers, :transport_type_id, :weather])
    end
  end
end

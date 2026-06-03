module Schools
  module TransportSurveys
    class ResponsesController < ApplicationController
      include Pagy::Backend
      load_resource :school
      load_and_authorize_resource :transport_survey, find_by: :run_on, id_param: :transport_survey_run_on, through: :school
      load_and_authorize_resource :response, class: 'TransportSurvey::Response', through: :transport_survey

      def destroy
        @response.destroy
        redirect_to school_transport_survey_responses_url(@school, @transport_survey), notice: t('schools.transport_surveys.responses.destroy.notice')
      end

      def index
        respond_to do |format|
          format.html { @pagy, @responses = pagy(@responses) }
          format.csv do
            send_data @responses.to_csv,
            filename: "#{t('common.application')}-#{TransportSurvey.model_name.human}-#{@school.slug}-#{@transport_survey.run_on}".parameterize + '.csv'
          end
        end
      end
    end
  end
end

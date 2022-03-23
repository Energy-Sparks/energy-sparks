module Schools
  module TransportSurveys
    class ResponsesController < ApplicationController
      load_resource :school
      load_resource :transport_survey, find_by: :run_on, id_param: :transport_survey_run_on, through: :school
      load_and_authorize_resource :response, class: 'TransportSurveyResponse', through: :transport_survey

      def destroy
        @response.destroy
        redirect_to school_transport_survey_url(@school, @transport_survey), notice: "Transport survey response was successfully destroyed."
      end
    end
  end
end

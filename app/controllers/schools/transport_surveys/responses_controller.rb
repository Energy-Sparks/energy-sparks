module Schools
  module TransportSurveys
    class ResponsesController < ApplicationController
      load_resource :school, :tranport_survey
      load_resource :transport_survey, through: :school
      load_resource :response, class: 'TransportSurveyResponse', through: :transport_survey
      load_and_authorize_resource :response, class: 'TransportSurveyResponse', through: :transport_survey

      # WIP - not currently working, need to sort permissions
      def destroy
        @response.destroy
        respond_to do |format|
          format.html { redirect_to schools_transport_survey_url(@school, @transport_survey), notice: "Transport survey response was successfully destroyed." }
          format.json { head :no_content }
        end
      end
    end
  end
end

module Schools
  module TransportSurveys
    class ResponsesController < ApplicationController
      load_resource :school, :tranport_survey
      load_resource :transport_survey, through: :school
      load_resource :response, class: 'TransportSurveyResponse', through: :transport_survey
      # load_and_authorize_resource :response, class: 'TransportSurveyResponse', through: :transport_survey

      # WIp
      def destroy
        @response.destroy
        respond_to do |format|
          format.html { redirect_to schools_transport_survey_url(@school, @transport_survey), notice: "Transport survey response was successfully destroyed." }
          format.json { head :no_content }
        end
      end

      private

      #def transport_survey_response_params
        # might need to make this stricter at some point
        #params.require(:transport_survey_response).permit(:id)
      #end
    end
  end
end

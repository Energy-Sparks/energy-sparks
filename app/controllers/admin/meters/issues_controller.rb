module Admin
  module Meters
    class IssuesController < AdminController
      load_and_authorize_resource :meter

      def index
        respond_to do |format|
          format.js
        end
      end
    end
  end
end

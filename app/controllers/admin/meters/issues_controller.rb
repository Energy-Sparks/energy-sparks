module Admin
  module Meters
    class IssuesController < AdminController
      load_and_authorize_resource :meter
      layout 'report'

      def index
        respond_to do |format|
          format.html
          format.js
        end
      end
    end
  end
end

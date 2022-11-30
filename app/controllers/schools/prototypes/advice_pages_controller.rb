module Schools
  module Prototypes
    class AdvicePagesController < ApplicationController
      load_and_authorize_resource :school
      def show
      end
    end
  end
end

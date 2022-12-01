module Schools
  module Prototypes
    class AdvicePagesController < ApplicationController
      load_resource :school
      skip_before_action :authenticate_user!
      def show
      end
    end
  end
end

module Schools
  class InactiveController < ApplicationController
    load_and_authorize_resource :school

    def show
    end
  end
end

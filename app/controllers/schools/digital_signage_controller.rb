module Schools
  class DigitalSignageController < ApplicationController
    load_and_authorize_resource :school

    def index
    end
  end
end

module Schools
  class ConsentGrantsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :consent_grant, through: :school

    def index
    end

    def show
    end
  end
end

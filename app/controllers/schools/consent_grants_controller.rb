module Schools
  class ConsentGrantsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :consent_grant, through: :school

    def index
      @consent_grants = @consent_grants.by_date
    end

    def show
    end
  end
end

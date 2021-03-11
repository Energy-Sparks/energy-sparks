module Admin
  class ConsentGrantsController < AdminController
    load_and_authorize_resource

    def index
      @consent_grants = @consent_grants.by_date
    end

    def show
    end
  end
end

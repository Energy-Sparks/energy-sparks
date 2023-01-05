module Admin
  class AdvicePagesController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    def index
    end

    def show
    end

    def edit
    end

    def update
    end

  private

    def advice_page_params
      translated_params = t_params(AdvicePage.mobility_attributes)
      params.require(:advice_page).permit(translated_params,
          :restricted
      )
    end
  end
end

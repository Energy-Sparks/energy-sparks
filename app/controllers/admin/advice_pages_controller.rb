module Admin
  class AdvicePagesController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    def index
      @advice_pages = @advice_pages.by_key
    end

    def edit; end

    def update
      if @advice_page.update(advice_page_params)
        redirect_to admin_advice_pages_path, notice: 'Advice Page updated'
      else
        render :edit
      end
    end

    private

    def advice_page_params
      translated_params = t_params(AdvicePage.mobility_attributes)
      params.require(:advice_page).permit(translated_params,
                                          :restricted)
    end
  end
end

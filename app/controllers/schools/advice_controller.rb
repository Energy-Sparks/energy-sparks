module Schools
  class AdviceController < ApplicationController
    load_and_authorize_resource :school

    def index
      @advice_pages = AdvicePage.all
    end

    def show
      @advice_pages = AdvicePage.all
      @advice_page = AdvicePage.find_by_key(params[:key])
      @tab = params[:tab] || 'insights'
    end
  end
end

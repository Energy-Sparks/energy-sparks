module Schools
  class AdviceController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!

    before_action :find_advice_page, only: :show
    before_action :check_authorisation, only: :show

    def index
      @advice_pages = AdvicePage.all
    end

    def show
      @advice_pages = AdvicePage.all
      @tab = params[:tab] || 'insights'
    end

    private

    def find_advice_page
      @advice_page = AdvicePage.find_by_key(params[:key])
    end

    def check_authorisation
      if @advice_page.restricted && cannot?(:read_restricted_advice, @school)
        redirect_to school_advice_path(@school), notice: 'Only an admin or staff user for this school can access this content'
      end
    end
  end
end

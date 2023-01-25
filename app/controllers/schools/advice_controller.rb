module Schools
  class AdviceController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!

    before_action :load_advice_pages

    include SchoolAggregation

    def show
    end

    private

    def load_advice_pages
      @advice_pages = AdvicePage.all.by_key
    end
  end
end

module Pupils
  class BaseController < ApplicationController
    load_and_authorize_resource :school

    before_action :set_adult_link
    skip_before_action :authenticate_user!

    private

    def set_adult_link
      @show_adult_link = true
    end
  end
end

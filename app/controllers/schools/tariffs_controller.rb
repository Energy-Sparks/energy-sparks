module Schools
  class TariffsController < ApplicationController
    load_resource :school

    def index
      @tariffs = params[:tariffs] || []
      if params[:step]
        render params[:step] and return
      end
    end
  end
end

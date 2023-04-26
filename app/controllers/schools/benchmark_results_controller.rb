module Schools
  class BenchmarkResultsController < ApplicationController
    load_and_authorize_resource :school

    def show
      @result = BenchmarkResult.find(params[:id])
      authorize! :read, @result
    end
  end
end

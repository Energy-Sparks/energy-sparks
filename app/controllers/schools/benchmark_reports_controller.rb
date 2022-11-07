module Schools
  class BenchmarkReportsController < ApplicationController
    load_and_authorize_resource :school

    def index
      authorize! :view_content_reports, @school
      @benchmark_result_school_generation_runs = @school.benchmark_result_school_generation_runs.order(created_at: :desc)
    end

    def show
      authorize! :view_content_reports, @school
      @run = @school.benchmark_result_school_generation_runs.find(params[:id])
    end
  end
end

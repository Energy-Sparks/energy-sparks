module Schools
  class BatchRunsController < ApplicationController
    load_and_authorize_resource :school

    def index
    end

    def show
      @school_batch_run = SchoolBatchRun.find(params[:id])
    end

    def create
      school_batch_run = SchoolBatchRun.create!(school: @school)
      SchoolBatchRunJob.perform_later school_batch_run
      redirect_to school_batch_run_path(@school, school_batch_run)
    end
  end
end

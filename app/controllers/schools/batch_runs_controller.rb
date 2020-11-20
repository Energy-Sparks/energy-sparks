module Schools
  class BatchRunsController < AdminController
    load_and_authorize_resource :school

    def index
      @school_batch_runs = @school.school_batch_runs.order(created_at: :desc)
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

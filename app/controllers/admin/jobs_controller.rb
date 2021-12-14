module Admin
  class JobsController < AdminController
    load_and_authorize_resource

    def index
      @jobs = Job.all.by_created_date
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      if @job.save
        redirect_to admin_jobs_path, notice: 'Job was successfully posted'
      else
        render :new
      end
    end

    def update
      if @job.update(job_params)
        redirect_to admin_jobs_path, notice: 'Job was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @job.destroy
      redirect_to admin_jobs_path, notice: 'Job was successfully deleted.'
    end

    private

    def job_params
      params.require(:job).permit(:title, :description, :file, :closing_date, :voluntary)
    end
  end
end

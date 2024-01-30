module Admin
  class ManualDataLoadRunsController < AdminController
    load_and_authorize_resource :amr_uploaded_reading

    # show the progress report
    def show
      @manual_data_load_run = ManualDataLoadRun.find(params[:id])
    end

    # create a job to load the data
    def create
      run = ManualDataLoadRun.create!(amr_uploaded_reading: @amr_uploaded_reading)
      ManualDataLoadRunJob.perform_later run
      redirect_to admin_amr_data_feed_config_amr_uploaded_reading_manual_data_load_run_path(@amr_uploaded_reading.amr_data_feed_config, @amr_uploaded_reading, run)
    end

    def destroy
      @manual_data_load_run = ManualDataLoadRun.find(params[:id])
      @manual_data_load_run.destroy!
      respond_to do |format|
        format.html { redirect_to admin_reports_data_loads_path, notice: 'Manual data load was successfully deleted.' }
        format.json { head :no_content }
      end
    end
  end
end

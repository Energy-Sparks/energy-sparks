module Admin
  class DataSourcesController < AdminController
    load_and_authorize_resource

    def show
    end

    def deliver
      @data_source = DataSource.find(params[:data_source_id])
      SendDataSourceReportJob.perform_later(to: current_user.email, data_source_id: @data_source.id)
      redirect_back fallback_location: admin_data_source_path(@data_source), notice: "Data source report for #{@data_source.name} requested to be sent to #{current_user.email}"
    end

    def create
      if @data_source.save
        redirect_to admin_data_sources_path, notice: 'Data source was successfully created.'
      else
        render :new
      end
    end

    def update
      if @data_source.update(data_source_params)
        redirect_to admin_data_source_path(@data_source), notice: 'Data source was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @data_source.destroy
      redirect_to admin_data_sources_path, notice: 'Data source was successfully deleted.'
    end

    private

    def data_source_params
      params.require(:data_source).permit(:name, :organisation_type, :contact_name, :contact_email, :loa_contact_details, :data_prerequisites, :data_feed_type, :new_area_data_feed, :add_existing_data_feed, :data_issues_contact_details, :historic_data, :loa_expiry_procedure, :comments, :load_tariffs)
    end
  end
end

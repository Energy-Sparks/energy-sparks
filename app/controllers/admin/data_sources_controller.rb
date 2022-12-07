module Admin
  class DataSourcesController < AdminController
    include Pagy::Backend
    before_action :header_fix_enabled
    load_and_authorize_resource

    def create
      if @data_source.save
        redirect_to params[:redirect_back], notice: 'Data source was successfully created.'
      else
        render :new
      end
    end

    def update
      if @data_source.update(data_source_params)
        redirect_to params[:redirect_back], notice: 'Data source was successfully updated.'
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
      params.require(:data_source).permit(:name, :organisation_type, :contact_name, :contact_email, :loa_contact_details, :data_prerequisites, :data_feed_type, :new_area_data_feed, :add_existing_data_feed, :data_issues_contact_details, :historic_data, :loa_expiry_procedure, :comments)
    end
  end
end

# frozen_string_literal: true

module Schools
  class SolarEdgeInstallationsController < BaseInstallationsController
    ID_PREFIX = 'solar-edge'
    NAME = 'SolarEdge API feed'
    JOB_CLASS = Solar::SolarEdgeLoaderJob

    def show
      @api_params = { api_key: @installation.api_key, format: :json }

      return unless @installation.cached_api_information?

      start_time = @installation.api_latest_data_date.strftime('%Y-%m-%d 00:00:00')
      end_time = @installation.api_latest_data_date.strftime('%Y-%m-%d 00:00:00')
      @reading_params = @api_params.merge({ timeUnit: 'QUARTER_OF_AN_HOUR', startTime: start_time,
                                            endTime: end_time })
    end

    def new; end

    def edit; end

    def create
      @installation = Solar::SolarEdgeInstallationFactory.new(
        school: @school,
        mpan: solar_edge_installation_params[:mpan],
        site_id: solar_edge_installation_params[:site_id],
        api_key: solar_edge_installation_params[:api_key],
        amr_data_feed_config: AmrDataFeedConfig.find(solar_edge_installation_params[:amr_data_feed_config_id])
      ).perform

      if @installation.persisted?
        redirect_to school_solar_feeds_configuration_index_path(@school),
                    notice: "#{NAME} was successfully created."
      else
        render :new
      end
    rescue StandardError => e
      Rollbar.error(e, job: :solar_download, school: @school)
      flash[:error] = e.message
      render :new
    end

    def update
      if @installation.update(solar_edge_installation_params)
        Solar::SolarEdgeInstallationFactory.update_information(@installation)
        redirect_to school_solar_feeds_configuration_index_path(@school), notice: "#{NAME} was updated"
      else
        render :edit
      end
    end

    def check
      @api_ok = Solar::SolarEdgeInstallationFactory.check(@installation)
      respond_to(&:js)
    end

    private

    def solar_edge_installation_params
      params.require(:solar_edge_installation).permit(
        :site_id, :amr_data_feed_config_id, :mpan, :api_key
      )
    end
  end
end

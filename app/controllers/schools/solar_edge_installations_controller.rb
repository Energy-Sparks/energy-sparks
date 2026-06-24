# frozen_string_literal: true

module Schools
  class SolarEdgeInstallationsController < BaseInstallationsController
    ID_PREFIX = 'solar-edge'
    NAME = 'SolarEdge API feed'
    JOB_CLASS = Solar::SolarEdgeLoaderJob

    def show
      @api_params = { api_key: @installation.api_key, format: :json }

      return unless @installation.cached_api_information?

      latest_date = @installation.api_latest_data_date
      start_time = (latest_date - 1.day).strftime('%Y-%m-%d 00:00:00')
      end_time = latest_date.strftime('%Y-%m-%d 00:00:00')
      @reading_params = @api_params.merge({ timeUnit: 'QUARTER_OF_AN_HOUR', startTime: start_time,
                                            endTime: end_time })
    end

    def new; end

    def edit; end

    def create
      @installation = Solar::SolarEdgeInstallationFactory.new(@installation,
                                                              AmrDataFeedConfig.solar_edge_api.first).perform

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
      params.expect(solar_edge_installation: %i[site_id amr_data_feed_config_id mpan api_key active])
    end
  end
end

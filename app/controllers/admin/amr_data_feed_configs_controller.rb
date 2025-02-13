# frozen_string_literal: true

module Admin
  class AmrDataFeedConfigsController < AdminController
    load_and_authorize_resource instance_name: :configuration
    def index
      @configurations = AmrDataFeedConfig.allow_manual.order(:description)
    end

    def show; end

    def edit; end

    def update
      if @configuration.update!(amr_data_feed_config_params)
        redirect_to admin_amr_data_feed_config_path(@configuration)
      else
        render :edit
      end
    end

    private

    def amr_data_feed_config_params
      params.require(:amr_data_feed_config)
            .permit(:description, :import_warning_days, :missing_readings_limit, :notes, :missing_reading_window,
                    :source_type, :owned_by_id)
    end
  end
end

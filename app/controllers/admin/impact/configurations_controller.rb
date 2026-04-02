# frozen_string_literal: true

module Admin
  module Impact
    class ConfigurationsController < AdminController
      before_action :enable_bootstrap5

      load_and_authorize_resource :school_group, include: :impact_report_configuration, id_param: :id, except: [:index]

      def index
        @school_groups = SchoolGroup.includes(:impact_report_configuration).order(:name)
      end

      def edit
        @configuration = @school_group.impact_report_configuration || @school_group.build_impact_report_configuration
      end

      def update
        @configuration = @school_group.impact_report_configuration || @school_group.build_impact_report_configuration
        @configuration.attributes = configuration_params if params[:impact_report_configuration].present?

        if @configuration.save
          redirect_to admin_impact_configurations_path,
                      notice: 'Configuration was successfully updated.' # rubocop:disable Rails/I18nLocaleTexts
        else
          render :edit
        end
      end

      private

      def configuration_params
        params.require(:impact_report_configuration).permit(:show_engagement)
      end
    end
  end
end

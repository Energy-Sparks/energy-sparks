# frozen_string_literal: true

module SchoolGroups
  module Impact
    class ConfigurationsController < AdminController
      include SchoolGroupBreadcrumbs

      layout 'group_settings'

      before_action :enable_bootstrap5
      load_and_authorize_resource :school_group, include: %i[
        impact_report_configuration
        latest_impact_report_run
      ]
      before_action :fetch_config_and_run, only: %i[edit update]
      before_action :breadcrumbs

      def show
        redirect_to edit_school_group_impact_configuration_path(@school_group)
      end

      def edit; end

      def update
        @configuration.attributes = configuration_params if params[:impact_report_configuration].present?

        if @configuration.save
          redirect_to edit_school_group_impact_configuration_path(@school_group),
                      notice: 'Configuration was successfully updated.' # rubocop:disable Rails/I18nLocaleTexts
        else
          render :edit
        end
      end

      private

      def fetch_config_and_run
        @configuration = @school_group.impact_report_configuration || @school_group.build_impact_report_configuration
        @run = @school_group.latest_impact_report_run
      end

      def configuration_params
        params.expect(impact_report_configuration:
          %i[visible show_engagement show_energy_efficiency
             engagement_school_id engagement_note engagement_image
             engagement_image_remove engagement_school_expiry_date
             energy_efficiency_school_id energy_efficiency_note energy_efficiency_image
             energy_efficiency_image_remove energy_efficiency_school_expiry_date])
      end

      def breadcrumbs
        build_breadcrumbs([{ name: t('school_groups.titles.impact_report') }])
      end
    end
  end
end

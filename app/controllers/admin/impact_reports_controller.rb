# frozen_string_literal: true

module Admin
  class ImpactReportsController < AdminController
    layout 'group_settings', except: [:index]

    before_action :enable_bootstrap5
    load_and_authorize_resource :school_group, include: :impact_report_configuration, id_param: :id, except: [:index]

    def index
      @school_groups = SchoolGroup.organisation_groups.includes(:impact_report_configuration).order(:name)
    end

    def edit
      @configuration = @school_group.impact_report_configuration || @school_group.build_impact_report_configuration
      # @impact_report = ::SchoolGroups::ImpactReport.new(@school_group)
    end

    def update
      @configuration = @school_group.impact_report_configuration || @school_group.build_impact_report_configuration
      @configuration.attributes = configuration_params if params[:impact_report_configuration].present?

      if @configuration.save
        redirect_to admin_impact_reports_path,
                    notice: 'Configuration was successfully updated.' # rubocop:disable Rails/I18nLocaleTexts
      else
        # @impact_report = ::SchoolGroups::ImpactReport.new(@school_group)
        render :edit
      end
    end

    private

    def configuration_params
      params.expect(impact_report_configuration:
        %i[show_report show_engagement show_energy_efficiency
           engagement_school_id engagement_note engagement_image
           engagement_image_remove engagement_school_expiry_date
           energy_efficiency_school_id energy_efficiency_note energy_efficiency_image
           energy_efficiency_image_remove energy_efficiency_school_expiry_date])
    end
  end
end

# frozen_string_literal: true

module Admin
  class ImpactReportsController < AdminController
    layout 'group_settings', except: [:index]

    before_action :enable_bootstrap5
    load_and_authorize_resource :school_group, include: :impact_report_configuration, id_param: :id, except: [:index]

    def index
      @school_groups = SchoolGroup.organisation_groups.with_active_schools
                                  .includes(:impact_report_configuration,
                                            :latest_impact_report_run,
                                            :default_issues_admin_user)
                                  .order(:name)
      @school_groups = @school_groups.where(default_issues_admin_user: params[:user]) if params[:user].present?
    end
  end
end

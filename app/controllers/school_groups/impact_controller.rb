module SchoolGroups
  class ImpactController < ApplicationController
    include SchoolGroupAccessControl
    include SchoolGroupBreadcrumbs

    load_resource :school_group
    before_action :redirect_unless_feature_enabled
    before_action :redirect_unless_authorised
    before_action :fetch_impact_report
    before_action :redirect_not_enough_data
    before_action :enable_prototype_page
    before_action :enable_bootstrap_5
    before_action :breadcrumbs

    skip_before_action :authenticate_user!

    def index
      # Eventually this will be replaced with an active record object or similar
      @impact_report = OpenStruct.new(
        schools_count: @school_group.assigned_schools.visible.count,
        generated_at: Time.zone.now
      )
    end

    private

    def fetch_impact_report
      # Eventually this will be replaced with an active record object or similar
      @impact_report = OpenStruct.new(
        schools_count: @school_group.assigned_schools.visible.count,
        generated_at: Time.zone.now
      )
    end

    def breadcrumbs
      build_breadcrumbs([{ name: I18n.t('school_groups.titles.impact_report') }])
    end

    def redirect_unless_feature_enabled
      unless Flipper.enabled?(:impact_reporting, current_user)
        redirect_back fallback_location: school_group_path(@school_group), alert: 'Feature not enabled'
      end
    end

    def redirect_not_enough_data
      unless @impact_report.schools_count >= 2
        redirect_back fallback_location: school_group_path(@school_group), alert: I18n.t('advice_pages.index.show.not_available')
      end
    end
  end
end

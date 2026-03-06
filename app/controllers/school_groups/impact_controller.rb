module SchoolGroups
  class ImpactController < ApplicationController
    include SchoolGroupAccessControl
    include SchoolGroupBreadcrumbs

    load_resource :school_group

    before_action :redirect_unless_authorised
    before_action :redirect_unless_enabled
    before_action :enable_prototype_page
    before_action :enable_bootstrap_5
    before_action :breadcrumbs

    skip_before_action :authenticate_user!

    def index
    end

    private

    def breadcrumbs
      build_breadcrumbs([{ name: I18n.t('school_groups.titles.impact_report') }])
    end

    def redirect_unless_enabled
      unless Flipper.enabled?(:impact_reporting, current_user)
        redirect_back fallback_location: school_group_path(@school_group), alert: 'Feature not enabled'
      end
    end
  end
end

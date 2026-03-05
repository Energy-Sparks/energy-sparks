module SchoolGroups
  class ImpactController < BaseController
    before_action :redirect_unless_authorised
    before_action :redirect_unless_enabled
    before_action :enable_bootstrap_5
    before_action :breadcrumbs

    def breadcrumbs
      build_breadcrumbs([{ name: I18n.t('school_groups.titles.impact_report') }])
    end

    def index
    end

    def redirect_unless_enabled
      unless Flipper.enabled?(:impact_reporting, current_user)
        redirect_back fallback_location: school_group_path(@school_group), alert: 'Feature not enabled'
      end
    end
  end
end

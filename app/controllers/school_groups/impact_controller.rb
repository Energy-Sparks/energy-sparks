# frozen_string_literal: true

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

    private

    def fetch_impact_report
      # Eventually this will be replaced with an active record object or similar
      @impact_report = SchoolGroups::ImpactReport.new(@school_group)
    end

    def breadcrumbs
      build_breadcrumbs([{ name: I18n.t('school_groups.titles.impact_report') }])
    end

    def redirect_unless_feature_enabled
      return if Flipper.enabled?(:impact_reporting, current_user)

      redirect_back_or_to(school_group_path(@school_group), alert: 'Feature not enabled')
    end

    def redirect_not_enough_data
      return if @impact_report.visible_schools_count >= 2

      redirect_back_or_to(school_group_path(@school_group),
                          alert: I18n.t('advice_pages.index.show.not_available'))
    end
  end
end

# frozen_string_literal: true

module SchoolGroups
  class ImpactController < ApplicationController
    include SchoolGroupAccessControl
    include SchoolGroupBreadcrumbs

    load_resource :school_group
    before_action :redirect_unless_feature_enabled
    before_action :load_data
    before_action :redirect_unless_authorised
    before_action :redirect_unless_visible
    before_action :redirect_not_enough_data
    before_action :enable_bootstrap5
    before_action :breadcrumbs

    skip_before_action :authenticate_user!

    private

    def load_data
      @config = @school_group.impact_report_configuration
      @run = @school_group.latest_impact_report_run
    end

    def breadcrumbs
      build_breadcrumbs([{ name: I18n.t('school_groups.titles.impact_report') }])
    end

    def redirect_not_available
      redirect_to(school_group_path(@school_group), alert: I18n.t('common.feature_not_available'))
    end

    def redirect_unless_feature_enabled
      return if Flipper.enabled?(:impact_reporting, current_user)

      redirect_not_available
    end

    def redirect_unless_visible
      return if @config&.visible || current_user&.admin?

      redirect_not_available
    end

    def redirect_not_enough_data
      return if @run&.enough_data?

      redirect_to(school_group_path(@school_group),
                  alert: I18n.t('advice_pages.index.show.not_available'))
    end
  end
end

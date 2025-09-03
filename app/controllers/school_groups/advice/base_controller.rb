module SchoolGroups
  module Advice
    class BaseController < ApplicationController
      include SchoolGroupAccessControl
      include SchoolGroupBreadcrumbs

      load_resource :school_group

      before_action :load_schools
      before_action :redirect_unless_authorised
      before_action :set_counts
      before_action :set_fuel_types
      before_action :breadcrumbs
      before_action :set_advice_page, only: [:insights, :analysis]
      before_action :set_tab_name, only: [:insights, :analysis]
      before_action :set_titles

      layout 'dashboards'

      skip_before_action :authenticate_user!

      def show
        redirect_to action: :insights
      end

      private

      def set_titles
        @page_title = t('page_title', scope: "school_groups.advice_pages.#{advice_page_key}", default: nil)
        @page_subtitle = t('page_subtitle', scope: "school_groups.advice_pages.#{advice_page_key}", default: nil)
      end

      def set_fuel_types
        @fuel_types = @school_group.fuel_types
      end

      # Rely on CanCan to filter the list of schools to those that can be shown to the current user
      def load_schools
        @schools = @school_group.schools.active.accessible_by(current_ability, :show).by_name
      end

      def set_counts
        @priority_action_count = SchoolGroups::PriorityActions.new(@schools).priority_action_count
        @alert_count = SchoolGroups::Alerts.new(@schools).summarise.count
      end

      def breadcrumbs
        build_breadcrumbs([
                            { name: I18n.t('advice_pages.breadcrumbs.root'), href: school_group_advice_path(@school_group) },
                            { name: I18n.t("advice_pages.#{advice_page_key}.page_title") }
                          ])
      end

      def set_advice_page
        @advice_page_key = advice_page_key
        @advice_page = AdvicePage.find_by!(key: advice_page_key)
        @advice_page_tab = advice_page_tab
      end

      def set_tab_name
        @tab = action_name.to_sym
      end
    end
  end
end

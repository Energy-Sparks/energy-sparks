module SchoolGroups
  module Advice
    class BaseController < ApplicationController
      include SchoolGroupAccessControl
      include SchoolGroupBreadcrumbs

      load_resource :school_group

      before_action :load_schools
      before_action :redirect_unless_authorised
      before_action :set_counts
      before_action :set_page_title
      before_action :breadcrumbs
      before_action :set_advice_page, only: [:insights, :analysis]
      before_action :set_tab_name, only: [:insights, :analysis]

      layout 'dashboards'

      skip_before_action :authenticate_user!

      def show
        redirect_to url_for([:insights, @school_group, :advice, advice_page_key])
      end

      private

      # Rely on CanCan to filter the list of schools to those that can be shown to the current user
      def load_schools
        @schools = @school_group.schools.active.accessible_by(current_ability, :show).by_name
      end

      def set_counts
        @priority_action_count = SchoolGroups::PriorityActions.new(@schools).priority_action_count
        @alert_count = SchoolGroups::Alerts.new(@schools).summarise.count
      end

      def set_page_title
        @advice_page_title = t("advice_pages.#{advice_page_key}.page_title")
      end

      def breadcrumbs
        build_breadcrumbs([name: I18n.t("advice_pages.#{advice_page_key}.page_title")])
      end

      def set_advice_page
        @advice_page_key = advice_page_key
      end

      def set_tab_name
        @tab = action_name.to_sym
      end
    end
  end
end

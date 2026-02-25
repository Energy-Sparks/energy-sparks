module SchoolGroups
  module Advice
    class BaseController < ApplicationController
      include SchoolGroupAccessControl
      include SchoolGroupBreadcrumbs
      include SchoolGroupAdvice

      load_resource :school_group

      before_action :load_schools
      before_action :redirect_unless_authorised
      before_action :set_counts
      before_action :set_fuel_types
      before_action :breadcrumbs
      before_action :set_advice_page, only: [:insights, :analysis]
      before_action :set_tab_name, only: [:insights, :analysis]
      before_action :set_titles, only: [:insights, :analysis]

      layout 'dashboards'

      skip_before_action :authenticate_user!

      def show
        redirect_to action: :insights
      end

      private

      def set_titles
        @page_title = t('page_title', scope: "school_groups.advice_pages.#{advice_page_key}", default: nil)
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

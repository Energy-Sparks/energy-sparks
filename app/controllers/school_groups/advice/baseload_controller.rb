module SchoolGroups
  module Advice
    class BaseloadController < BaseController
      include SchoolGroupAccessControl
      include SchoolGroupBreadcrumbs

      load_resource :school_group

      def insights
      end

      def analysis
      end

      private

      def breadcrumbs
        build_breadcrumbs([
                            { name: I18n.t('advice_pages.breadcrumbs.root'), href: school_group_advice_path(@school_group) },
                            { name: I18n.t("advice_pages.#{advice_page_key}.page_title") }
                          ])
      end

      def advice_page_key
        :baseload
      end
    end
  end
end

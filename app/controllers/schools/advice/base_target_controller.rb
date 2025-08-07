# frozen_string_literal: true

module Schools
  module Advice
    class BaseTargetController < AdviceBaseController
      def insights
        @target = @school.most_recent_target
      end

      private

      def advice_page_key
        @fuel_type = self.class.name.split('::').last.underscore.split('_').first.to_sym
        :"#{@fuel_type}_target"
      end

      def set_page_subtitle
        @advice_page_subtitle = I18n.t('advice_pages.target.insights.what_is_your_target.title')
      end
    end
  end
end

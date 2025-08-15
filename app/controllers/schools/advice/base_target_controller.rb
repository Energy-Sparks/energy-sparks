# frozen_string_literal: true

module Schools
  module Advice
    class BaseTargetController < AdviceBaseController
      before_action :set_target, only: %i[insights analysis]

      def insights; end

      def analysis; end

      private

      def set_target
        @target = @school.most_recent_target
        redirect_to school_school_targets_path(@school) and return if @target.nil?

        consumption = @target.monthly_consumption(@fuel_type)
        render 'not_enough_data' and return if consumption.nil?

        # debugger
        consumption.reject! { |month| month[:missing] }
        @last_consumption_month = consumption.last
        @current_consumption = consumption.sum { |month| month[:current_consumption] }
        @target_consumption = consumption.sum { |month| month[:target_consumption] }
      end

      def advice_page_key
        @fuel_type = self.class.name.split('::').last.underscore.split('_').first.to_sym
        :"#{@fuel_type}_target"
      end

      def set_page_subtitle
        @advice_page_subtitle = I18n.t('advice_pages.target.insights.what_is_your_target.title')
      end

      def percent_change(current_consumption, target_consumption)
        (current_consumption - target_consumption) / target_consumption
      end

      helper_method :percent_change
    end
  end
end

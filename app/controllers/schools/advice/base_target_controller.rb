# frozen_string_literal: true

module Schools
  module Advice
    class BaseTargetController < AdviceBaseController
      include ApplicationHelper

      before_action :set_target, only: %i[insights analysis]
      before_action :set_consumption, only: %i[insights analysis]

      def insights; end

      def analysis; end

      private

      def set_target
        @target = @school.most_recent_target
        redirect_to school_school_targets_path(@school) if @target.nil?
      end

      def set_consumption
        consumption = @target.monthly_consumption(@fuel_type, missing: false)
        render 'not_enough_data' and return if consumption.nil?

        @last_consumption_month = consumption.last
        @current_consumption = consumption.sum { |month| month[:current_consumption] }
        @target_consumption = consumption.sum { |month| month[:target_consumption] }
      end

      def advice_page_key
        @fuel_type = self.class.name.split('::').last.underscore.split('_')[..-3].join('_').to_sym
        :"#{@fuel_type}_target"
      end

      def set_page_subtitle
        super(section: 'target')
      end

      def percent_change(current_consumption, target_consumption)
        (current_consumption - target_consumption) / target_consumption.to_f
      end
      # helper_method :percent_change

      def formatted_target(target = nil)
        format_unit((target || @target).target(@fuel_type), { units: :percent, options: { scale: false } })
      end
      helper_method :formatted_target

      def target_strftime(date)
        date.strftime('%B %Y')
      end
      helper_method :target_strftime

      def formatted_target_date(target = nil)
        target_strftime((target || @target).target_date)
      end
      helper_method :formatted_target_date

      def formatted_target_change(current_consumption, target_consumption)
        change = percent_change(current_consumption, target_consumption)
        up_downify(format_unit(change, :relative_percent, true, :target), sanitize: false)
      end
      helper_method :formatted_target_change
    end
  end
end

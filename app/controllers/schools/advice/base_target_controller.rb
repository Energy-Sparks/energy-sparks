# frozen_string_literal: true

module Schools
  module Advice
    class BaseTargetController < AdviceBaseController
      include ApplicationHelper

      before_action :set_target, only: %i[insights analysis]
      before_action :set_consumption, only: %i[insights analysis]

      def insights; end

      def analysis
        @historical_targets = @school.school_targets.by_start_date.filter_map do |target|
          [target, target.monthly_consumption(@fuel_type)] unless target == @target
        end
      end

      private

      def set_target
        @target = @school.most_recent_target
        redirect_to school_school_targets_path(@school) if @target.nil?
      end

      def set_consumption
        @consumption = ActiveSupport::OrderedOptions.new
        @consumption.data = @target.monthly_consumption(@fuel_type)
        render 'new_target' and return if @consumption.data.nil?

        non_missing = @consumption.data.reject { |month| month[:missing] }
        @consumption.last_month = non_missing.last
        @consumption.current = non_missing.sum { |month| month[:current_consumption] }
        @consumption.target = non_missing.sum { |month| month[:target_consumption] }
      end

      def advice_page_key
        @fuel_type = self.class.name.split('::').last.underscore.split('_')[..-3].join('_').to_sym
        :"#{@fuel_type}_target"
      end

      def percent_change(current_consumption, target_consumption)
        (current_consumption - target_consumption) / target_consumption.to_f
      end

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

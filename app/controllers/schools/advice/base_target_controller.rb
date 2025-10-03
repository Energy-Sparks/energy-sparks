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
        redirect_to school_school_targets_path(@school) and return if @target.nil? && can?(:manage, SchoolTarget)

        render 'no_target' if @target&.target(@fuel_type).nil?
      end

      def set_consumption
        @consumption = @target.monthly_consumption_status(@fuel_type)
        render 'new_target' and return if @consumption.consumption.nil?

        render 'limited_data' and return if @consumption.consumption.any? { |month| month[:previous_consumption].nil? }
      end

      def advice_page_key
        @fuel_type = self.class.name.split('::').last.underscore.split('_')[..-3].join('_').to_sym
        :"#{@fuel_type}_target"
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

      def percent_change(current_consumption, previous_consumption)
        (current_consumption - previous_consumption) / previous_consumption.to_f
      end

      def formatted_target_change(current_consumption, previous_consumption)
        return '-' if current_consumption.nil? || previous_consumption.nil? || previous_consumption.zero?

        change = percent_change(current_consumption, previous_consumption)
        up_downify(format_unit(change, :relative_percent, true, :target), sanitize: false)
      end
      helper_method :formatted_target_change

      def t_fuel_type
        t("advice_pages.fuel_type.#{@fuel_type}")
      end
      helper_method :t_fuel_type
    end
  end
end

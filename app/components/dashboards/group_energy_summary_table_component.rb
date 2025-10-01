module Dashboards
  class GroupEnergySummaryTableComponent < ApplicationComponent
    PERIODS = %w[week month year].freeze
    attr_reader :school_group, :schools, :fuel_type, :periods, :metric

    renders_one :modal_link

    def initialize(school_group:, schools:, fuel_type:, metric: :change, periods: PERIODS, show_clusters: false, **kwargs)
      super
      @school_group = school_group
      @schools = schools
      @fuel_type = fuel_type
      @metric = metric
      @show_clusters = show_clusters
      @periods = periods.map(&:to_sym)
    end

    def show_clusters?
      @show_clusters
    end

    def render?
      @schools.any? && @periods.any?
    end

    def period_label(period)
      I18n.t("common.labels.last_#{period}")
    end

    private

    def value_for(recent_usage, formatted: true)
      return nil unless recent_usage
      case @metric
      when :usage then formatted ? recent_usage.usage : recent_usage.usage_text
      when :co2 then formatted ? recent_usage.co2 : recent_usage.co2_text
      when :cost then formatted ? recent_usage.cost : recent_usage.cost_text
      else
        formatted ? recent_usage.change : recent_usage.change_text.gsub(/[^-.0-9]/, '')
      end
    end
  end
end

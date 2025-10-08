module Dashboards
  class GroupAdvicePageListComponent < ApplicationComponent
    attr_reader :school_group, :fuel_types
    GROUP_ADVICE_PAGES = %w[baseload electricity_long_term electricity_out_of_hours gas_long_term gas_out_of_hours heating_control].freeze

    include ApplicationHelper
    include AdvicePageHelper

    def initialize(school_group:, schools:, fuel_types:, **kwargs)
      super
      @school_group = school_group
      @schools = schools.data_enabled
      @fuel_types = fuel_types
    end

    def advice_pages
      @advice_pages ||= AdvicePage.where(key: Dashboards::GroupAlertsComponent::GROUP_ADVICE_PAGES).group_by(&:fuel_type).symbolize_keys
    end

    def render?
      @schools.any? && @fuel_types.any?
    end
  end
end

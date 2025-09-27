module Dashboards
  class GroupEnergySummaryComponent < ApplicationComponent
    attr_reader :school_group, :schools, :fuel_types, :metric

    def initialize(school_group:, schools:, fuel_types:, metric: :change, show_clusters: false, **kwargs)
      super
      @school_group = school_group
      @schools = schools
      fuel_types.delete(:solar_pv)
      @fuel_types = fuel_types.sort
      @metric = metric&.to_sym
      @show_clusters = show_clusters
    end

    def show_clusters?
      @show_clusters
    end

    def render?
      @schools.any? && @fuel_types.any?
    end
  end
end

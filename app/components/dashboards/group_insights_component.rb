module Dashboards
  class GroupInsightsComponent < ApplicationComponent
    attr_reader :school_group, :user

    def initialize(school_group:, user:, **kwargs)
      super
      @school_group = school_group
      @user = user
    end
  end
end

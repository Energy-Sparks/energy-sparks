# frozen_string_literal: true

module Scoreboards
  class PodiumComponent < ApplicationComponent
    attr_reader :podium, :id, :user, :i18n_scope

    def initialize(podium: nil, classes: nil, id: nil, user: nil, i18n_scope: 'components.podium', **_kwargs)
      super
      @podium = podium
      @user = user
      @i18n_scope = i18n_scope
    end

    def school
      podium.school
    end

    def national_podium
      podium.national_podium
    end

    def render?
      podium
    end
  end
end

# frozen_string_literal: true

class PodiumComponent < ApplicationComponent
  attr_reader :podium, :id, :user

  def initialize(podium: nil, classes: nil, id: nil, user: nil, **_kwargs)
    super
    @podium = podium
    @user = user
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

  def title_class
    Flipper.enabled?(:new_dashboards_2024, user) ? 'mb-4' : 'text-center'
  end
end

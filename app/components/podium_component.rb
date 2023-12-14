# frozen_string_literal: true

class PodiumComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :podium, :id

  def initialize(podium: nil, classes: nil, id: nil)
    @podium = podium
    @classes = classes
    @id = id
  end

  def classes
    " #{@classes}"
  end

  def school
    podium.school
  end

  def render?
    podium
  end
end

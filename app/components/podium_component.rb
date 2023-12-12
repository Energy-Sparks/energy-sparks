# frozen_string_literal: true

class PodiumComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :podium, :id, :school_focus

  def initialize(podium: nil, classes: nil, id: nil, school_focus: true)
    @podium = podium
    @classes = classes
    @id = id
    @school_focus = school_focus
  end

  def classes
    " #{@classes}"
  end

  def render?
    podium
  end
end

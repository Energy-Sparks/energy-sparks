# frozen_string_literal: true

class TimelineComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :observations, :show_actions, :id

  def initialize(observations:, show_actions: false, classes: nil, id: nil)
    @observations = observations
    @show_actions = show_actions
    @classes = classes
    @id = id
  end

  def classes
    " #{@classes}"
  end

  def render?
    observations&.any?
  end
end

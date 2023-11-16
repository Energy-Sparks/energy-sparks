# frozen_string_literal: true

class PodiumComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :podium

  def initialize(podium:, classes: "")
    @podium = podium
    @classes = classes
  end

  def classes
    " #{@classes}"
  end
end

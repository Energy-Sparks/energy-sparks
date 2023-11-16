# frozen_string_literal: true

class PodiumComponent < ViewComponent::Base
  include ApplicationHelper

  attr_accessor :podium

  def initialize(podium:)
    @podium = podium
  end

  def classes
    " #{@classes}"
  end
end

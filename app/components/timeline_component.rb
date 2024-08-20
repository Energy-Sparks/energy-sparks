# frozen_string_literal: true

class TimelineComponent < ApplicationComponent
  include ApplicationHelper

  attr_reader :observations, :show_actions, :id, :user, :school, :show_header

  def initialize(observations:,
                 school: nil,
                 show_actions: false,
                 show_header: true,
                 classes: nil,
                 id: nil,
                 user: nil)
    @observations = observations
    @show_actions = show_actions
    @show_header = show_header
    @classes = classes
    @id = id
    @user = user
    @school = school
  end

  def classes
    " #{@classes}"
  end

  def render?
    observations&.any?
  end
end

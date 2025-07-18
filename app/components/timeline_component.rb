# frozen_string_literal: true

class TimelineComponent < ApplicationComponent
  attr_reader :observations, :show_actions, :user, :school, :show_header, :observation_style

  def initialize(observations:,
                 school: nil,
                 show_actions: false,
                 show_header: true,
                 observation_style: :description,
                 user: nil,
                 **_kwargs)
    super
    @observations = observations
    @show_actions = show_actions
    @show_header = show_header
    @user = user
    @school = school
    @observation_style = observation_style
  end

  def render?
    observations&.any?
  end
end

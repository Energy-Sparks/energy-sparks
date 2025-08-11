# frozen_string_literal: true

class TimelineComponent < ApplicationComponent
  attr_reader :observations, :user, :show_header, :formatting_args

  renders_one :link
  renders_one :title
  renders_one :description

  def initialize(observations:,
                 show_header: true,
                 user: nil,
                 table_opts: {},
                 **kwargs)
    super
    @observations = observations
    @user = user
    @show_header = show_header
    @formatting_args = default_table_options.merge(table_opts)
  end

  def render?
    observations&.any?
  end

  private

  def default_table_options
    {
      show_actions: false,
      show_date: false,
      show_positions: false,
      show_school: false,
      observation_style: :description
    }
  end
end

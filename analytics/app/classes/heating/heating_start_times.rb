# frozen_string_literal: true

module Heating
  class HeatingStartTimes
    attr_reader :days, :average_start_time

    def initialize(days:, average_start_time:)
      @days = days
      @average_start_time = average_start_time
    end
  end
end

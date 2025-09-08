# frozen_string_literal: true

module Baseload
  class SeasonalVariation
    attr_reader :summer_kw, :winter_kw, :percentage

    def initialize(summer_kw:, winter_kw:, percentage:)
      @summer_kw = summer_kw
      @winter_kw = winter_kw
      @percentage = percentage
    end
  end
end

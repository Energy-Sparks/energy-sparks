# frozen_string_literal: true

class MeterBreakdownTableComponent < ViewComponent::Base
  def initialize(headers:, rows:, footers:, options:)
    @headers = headers
    @rows = rows
    @footers = footers
    @options = options
  end
end

# frozen_string_literal: true

class DccCheckerJob < ApplicationJob
  queue_as :default

  def perform(meter, to)
    Meters::DccChecker.new([meter]).perform(to)
  end
end

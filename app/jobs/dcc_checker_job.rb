class DccCheckerJob < ApplicationJob
  queue_as :default

  def priority
    5
  end

  def perform(meter)
    Meters::DccChecker.new([meter]).perform
  end
end

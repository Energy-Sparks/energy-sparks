class DccCheckerJob < ApplicationJob
  queue_as :default

  def perform(meter)
    Meters::DccChecker.new([meter]).perform
  end
end

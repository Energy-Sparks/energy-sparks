class DccCheckerJob < ApplicationJob
  self.queue_adapter = :delayed_job
  queue_as :default

  def perform(meter)
    Meters::DccChecker.new([meter]).perform
  end
end

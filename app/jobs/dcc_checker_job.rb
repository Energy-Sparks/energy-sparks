class DccCheckerJob < ApplicationJob
  self.queue_adapter = :delayed_job
  queue_as :default

  def perform(meter)
    ActiveRecord::Base.transaction do
      Meters::DccChecker.new([meter]).perform
    end
  end
end

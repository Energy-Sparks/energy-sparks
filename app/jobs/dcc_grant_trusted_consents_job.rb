class DccGrantTrustedConsentsJob < ApplicationJob
  self.queue_adapter = :good_job
  queue_as :default

  def perform(meters)
    Meters::DccGrantTrustedConsents.new(meters).perform
  end
end

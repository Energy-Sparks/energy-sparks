class DccGrantTrustedConsentsJob < ApplicationJob
  self.queue_adapter = :delayed_job
  queue_as :default

  def perform(meters)
    ActiveRecord::Base.transaction do
      Meters::DccGrantTrustedConsents.new(meters).perform
    end
  end
end

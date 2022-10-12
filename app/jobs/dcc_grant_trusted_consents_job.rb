class DccGrantTrustedConsentsJob < ApplicationJob
  queue_as :default

  def priority
    5
  end

  def perform(meters)
    Meters::DccGrantTrustedConsents.new(meters).perform
  end
end

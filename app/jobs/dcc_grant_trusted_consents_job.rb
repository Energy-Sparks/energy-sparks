class DccGrantTrustedConsentsJob < ApplicationJob
  queue_as :default

  def perform(meters)
    Meters::DccGrantTrustedConsents.new(meters).perform
  end
end

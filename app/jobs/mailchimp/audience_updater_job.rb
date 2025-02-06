module Mailchimp
  class AudienceUpdaterJob < ApplicationJob
    def perform
      Mailchimp::AudienceUpdater.new.perform
    rescue => e
      EnergySparks::Log.exception(e, job: :audience_updater)
    end
  end
end

module Mailchimp
  class AudienceUpdaterJob < BaseJob
    def perform
      return unless can_run?

      Mailchimp::AudienceUpdater.new.perform
    rescue => e
      EnergySparks::Log.exception(e, job: :audience_updater)
    end
  end
end

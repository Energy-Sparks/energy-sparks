module Mailchimp
  class AudienceUpdaterJob < ApplicationJob
    def perform
      Mailchimp::AudienceUpdater.new.perform
    rescue => e
      Rollbar.log(e, job: :audience_updater)
      EnergySparks::Log.exception(e, job: :audience_updater)
    end
  end
end

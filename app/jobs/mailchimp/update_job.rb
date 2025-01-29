class Mailchimp::UpdateJob < ApplicationJob
  queue_as :default

  def perform(model)
    service = Mailchimp::UpdateCreator.for(model)
    service.create_updates
  rescue => e
    Rollbar.error(e, job: :mailchimp_update_job)
  end
end

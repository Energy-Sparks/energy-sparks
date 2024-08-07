class CampaignContactHandlerJob < ApplicationJob
  queue_as :default

  def perform(request_type, contact)
    Campaigns::ContactHandlerService.new(request_type, contact).perform
  rescue => e
    Rollbar.error(e, job: :campaign_contact_handler)
  end
end

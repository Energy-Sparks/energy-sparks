class N3rgyReloadJob < ApplicationJob
  queue_as :default

  def perform(meter, notify_email)
    config = AmrDataFeedConfig.n3rgy_api.first
    @import_log = Amr::N3rgyReadingsDownloadAndUpsert.new(meter:, config:, reload: true).perform
    N3rgyReloadJobMailer.with(to: notify_email, meter:, import_log:).complete
  end
end

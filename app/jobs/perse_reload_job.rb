# frozen_string_literal: true

class PerseReloadJob < ApplicationJob
  queue_as :default

  def perform(meter, notify_email)
    result = Amr::PerseUpsert.new.perform(meter, reload: true)
    N3rgyReloadJobMailer.with(to: notify_email, meter:, result:).complete.deliver
  end
end

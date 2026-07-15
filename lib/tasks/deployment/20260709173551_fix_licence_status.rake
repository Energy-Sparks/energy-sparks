# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: fix_licence_status'
  task fix_licence_status: :environment do
    puts "Running deploy task 'fix_licence_status'"

    # Find confirmed contracts and licences where the school is data enabled and set the
    # licence to be 'pending_invoice'. Corrects for an existing bug where this status should
    # have been used already.
    Commercial::Licence
      .joins(:contract, :school)
      .where(start_date: Time.zone.today..)
      .where(commercial_contracts: { status: 'confirmed' })
      .merge(School.where(data_enabled: true))
      .update_all(status: 'pending_invoice') # rubocop:disable Rails/SkipsModelValidations

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

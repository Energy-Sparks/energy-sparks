# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: add_xero_account_codes'
  task add_xero_account_codes: :environment do
    puts "Running deploy task 'add_xero_account_codes'"

    [
      [29, 'State school fees (all individual state school and MAT contracts)'],
      [24, 'Independent school fees (private school contracts)'],
      [30, 'Community Energy Sponsorship']
    ].each do |data|
      Commercial::XeroAccountCode.find_or_create_by(code: data.first) do |code|
        code.assign_attributes(label: data.last)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: set_default_account_codes'
  task set_default_account_codes: :environment do
    puts "Running deploy task 'set_default_account_codes'"

    # Set default account code unless already set on the contract
    xero_account_code = Commercial::XeroAccountCode.find_by(code: 29)
    Commercial::Contract.where(xero_account_code: nil).find_each do |c|
      c.update(xero_account_code:)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

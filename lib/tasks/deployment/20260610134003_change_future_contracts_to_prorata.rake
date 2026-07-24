# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: change_future_contracts_to_prorata'
  task change_future_contracts_to_prorata: :environment do
    puts "Running deploy task 'change_future_contracts_to_prorata'"

    Commercial::Contract.future
                        .where(licence_period: :contract, invoice_terms: :full)
                        .where(contract_holder: SchoolGroup.all).find_each do |c|
      c.update_attribute!(:invoice_terms, :pro_rata)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

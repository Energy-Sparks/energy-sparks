namespace :after_party do
  desc 'Deployment task: remove_n3rgy_zero_tariff_prices'
  task remove_n3rgy_zero_tariff_prices: :environment do
    puts "Running deploy task 'remove_n3rgy_zero_tariff_prices'"

    # Put your task implementation HERE.
    zero_prices_array = Array.new(48, 0.0)

    ActiveRecord::Base.transaction do
      tariff_prices = TariffPrice.joins(:meter)
                                 .joins(:tariff_import_log)
                                 .where("tariff_import_logs.source = 'n3rgy-api'")
                                 .where('meters.dcc_meter = true')
                                 .where(prices: zero_prices_array)

      tariff_prices.delete_all
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

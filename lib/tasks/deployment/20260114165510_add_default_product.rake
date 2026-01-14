namespace :after_party do
  desc 'Deployment task: add_default_product'
  task add_default_product: :environment do
    puts "Running deploy task 'add_default_product'"

    Commercial::Product.create!(
      name: 'Energy Sparks Standard',
      default: true,
      comments: 'Our standard product. Prices for this will be used on the website',
      small_school_price: 545.0,
      large_school_price: 595.0,
      size_threshold: 250,
      mat_price: 545.0,
      private_account_fee: 95.0,
      metering_fee: 25.0
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

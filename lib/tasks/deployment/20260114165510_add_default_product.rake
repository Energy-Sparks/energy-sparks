namespace :after_party do
  desc 'Deployment task: add_default_product'
  task add_default_product: :environment do
    puts "Running deploy task 'add_default_product'"

    Commercial::Product.find_or_create_by!(default_product: true) do |product|
      product.name                 = 'Energy Sparks Standard'
      product.comments             = 'Our standard product. Prices for this will be used on the website'
      product.small_school_price   = 545.0
      product.large_school_price   = 595.0
      product.size_threshold       = 250
      product.mat_price            = 545.0
      product.private_account_fee  = 95.0
      product.metering_fee         = 25.0
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

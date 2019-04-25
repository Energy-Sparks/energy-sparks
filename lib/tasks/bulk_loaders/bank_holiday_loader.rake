namespace :loader do
  desc 'Load bank holiday data'
  task bank_holidays: [:environment] do
    puts Time.zone.now
    Loader::BankHolidays.load!("etc/bank_holidays/england-and-wales.json")
    puts Time.zone.now
  end
end

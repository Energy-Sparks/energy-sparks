namespace :loader do
  desc 'Load bank holiday data'
  task bank_holidays: [:environment] do
    puts Time.zone.now
    area = Area.where(title: 'England and Wales').first_or_create
    file = File.read('etc/bank_holidays/england-and-wales.json')

    json = JSON.parse(file)
    json["events"].each do |bh|
      BankHoliday.where(title: bh["title"], holiday_date: bh["date"], notes: bh["notes"], area: area).first_or_create
    end
    puts Time.zone.now
  end

end

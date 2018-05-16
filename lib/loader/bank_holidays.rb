module Loader
  class BankHolidays
    # load default calendar from csv
    def self.load!(json_file_path = 'etc/bank_holidays/england-and-wales.json')
      group = Group.where(title: 'England and Wales').first_or_create
      file = File.read(json_file_path)

      json = JSON.parse(file)
      json["events"].each do |bh|
        BankHoliday.where(title: bh["title"], holiday_date: bh["date"], notes: bh["notes"], group: group).first_or_create
      end
    end
  end
end

module Loader
  class BankHolidays
    # load default calendar from csv
    #
    # Download the JSON from: https://www.gov.uk/bank-holidays.json
    # This job can be re-run as soon as the bank holidays json file is updated
    #
    def self.load!(json_file_path = 'etc/bank_holidays/bank-holidays.json')
      file = File.read(json_file_path)
      json = JSON.parse(file)
      bank_holiday_type = CalendarEventType.bank_holiday.first

      Calendar.national.each do |calendar|
        puts "Processing calendar: #{calendar.title} - bh before: #{calendar.bank_holidays.count}"

        json[calendar.title.parameterize]['events'].each do |bank_holiday|
          CalendarEvent.where(
            calendar: calendar,
            calendar_event_type: bank_holiday_type,
            start_date: bank_holiday['date'],
            end_date: bank_holiday['date'],
            description: bank_holiday['notes']
          ).first_or_create!
        end

        puts "Processing calendar: #{calendar.title} - bh after: #{calendar.calendar_events.bank_holidays.count}"
      end
    end
  end
end

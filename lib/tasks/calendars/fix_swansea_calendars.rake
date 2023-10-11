namespace :calendars do
  desc 'Fix Swansea calendars'
  task fix_swansea_calendars: [:environment] do
    swansea_calendar = Calendar.regional.find_by(title: 'Swansea')
    pp 'Checking Swansea calendars..'
    ignored = []
    swansea_calendar.calendars.each do |calendar|
      if calendar.calendar_events.count == swansea_calendar.calendar_events.count
        pp "#{calendar.title} has same event count - resetting"
        CalendarResetService.new(calendar).reset
      else
        pp "#{calendar.title} has DIFFERENT event count - ignoring"
        ignored << calendar
      end
    end
    if ignored.any?
      pp '##############'
      pp 'please update these calendars manually: '
      pp ignored.map(&:title).join(',').to_s
      pp '##############'
    end
    pp 'Finished'
  end
end

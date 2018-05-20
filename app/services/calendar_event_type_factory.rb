class CalendarEventTypeFactory
  def self.create
    term_colour = 'rgb(245, 187, 0)'
    CalendarEventType.where(title: 'Term 1', description: 'Autumn Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 2', description: 'Autumn Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 3', description: 'Spring Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 4', description: 'Spring Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 5', description: 'Summer Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 6', description: 'Autumn Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create

    CalendarEventType.where(title: CalendarEventType::INSET_DAY, description: 'Training day', school_occupied: true, term_time: false, colour: 'rgb(255, 74, 50)').first_or_create

    BankHoliday.pluck(:title).uniq.each do |bh_title|
      CalendarEventType.where(title: 'Bank Holiday', description: bh_title, school_occupied: false, term_time: false, holiday: true, colour: 'rgb(255, 74, 50)').first_or_create
    end

    CalendarEventType.all
  end
end

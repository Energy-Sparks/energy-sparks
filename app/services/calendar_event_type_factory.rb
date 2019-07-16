# frozen_string_literal: true

class CalendarEventTypeFactory
  def self.create
    term_colour = 'rgb(255,172,33)'
    inset_day_colour = 'rgb(255,69,0)'
    inset_day_out_colour = 'rgb(181, 108, 226)'
    bank_holiday_colour = 'rgb(59,192,240)'
    holiday_colour = 'rgb(92,184,92)'

    CalendarEventType.where(title: 'Term 1', description: 'Autumn Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 2', description: 'Autumn Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 3', description: 'Spring Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 4', description: 'Spring Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 5', description: 'Summer Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 6', description: 'Autumn Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create

    CalendarEventType.where(title: 'Holiday', description: 'Holiday', holiday: true, colour: holiday_colour, school_occupied: false, term_time: false).first_or_create
    raise ArgumentError unless BankHoliday.any?
    CalendarEventType.where(title: 'Bank Holiday', description: 'Bank Holiday', school_occupied: false, term_time: false, bank_holiday: true, holiday: false, colour: bank_holiday_colour).first_or_create

    CalendarEventType.where(title: "In school #{CalendarEventType::INSET_DAY}", description: 'Training day in school', school_occupied: true, term_time: false, inset_day: true, colour: inset_day_colour).first_or_create
    CalendarEventType.where(title: "Out of school #{CalendarEventType::INSET_DAY}", description: 'Training day out of school', school_occupied: false, term_time: false, inset_day: true, colour: inset_day_out_colour).first_or_create

    CalendarEventType.all
  end
end

# $yellow: #ffee8f; // term times? rgb(255,238,143)
# $light-orange: #ffac21; // orange  rgb(255,172,33)
# $dark-orange: #ff4500 // almost red; rgb(255,69,0)

# $light-blue: #3bc0f0; // cyanish rgb(59,192,240)
# $dark-blue: #232b49; // very dark blue rgb(35,43,73)

# $green: #5cb85c; // nice green rgb(92,184,92)

module EnergySparksDataHelpers
  def create_active_school(*args)
    create(:school, *args).tap do |school|
      school_creator = SchoolCreator.new(school)
      school_creator.process_new_school!
      school_creator.process_new_configuration!
    end
  end

  def create_all_calendar_events
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

    CalendarEventType.where(title: 'Holiday', description: 'Holiday', holiday: true, colour: holiday_colour, school_occupied: false, term_time: false, analytics_event_type: :school_holiday).first_or_create
    CalendarEventType.where(title: 'Bank Holiday', description: 'Bank Holiday', school_occupied: false, term_time: false, bank_holiday: true, holiday: false, colour: bank_holiday_colour, analytics_event_type: :bank_holiday).first_or_create

    CalendarEventType.where(title: "In school #{CalendarEventType::INSET_DAY}", description: 'Training day in school', school_occupied: true, term_time: false, inset_day: true, colour: inset_day_colour, analytics_event_type: :inset_day_in_school).first_or_create
    CalendarEventType.where(title: "Out of school #{CalendarEventType::INSET_DAY}", description: 'Training day out of school', school_occupied: false, term_time: false, inset_day: true, colour: inset_day_out_colour, analytics_event_type: :inset_day_out_of_school).first_or_create

    CalendarEventType.all
  end
end

RSpec.configure do |config|
  config.include EnergySparksDataHelpers
end

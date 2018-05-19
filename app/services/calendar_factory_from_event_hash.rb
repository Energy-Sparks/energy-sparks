class CalendarFactoryFromEventHash
  def initialize(event_hash, area, template = false)
    @event_hash = event_hash
    @area = area
    @template = template
  end

  def create
    @calendar = Calendar.where(default: @template, area: @area, title: @area.title, template: @template).first_or_create

    make_sure_calendar_event_types_created

    @event_hash.each do |event|
      event_type = CalendarEventType.select { |cet| event[:term].include? cet.title }.first

      academic_year = AcademicYear.where('start_date <= ? and end_date >= ?', Date.parse(event[:start_date]), Date.parse(event[:start_date])).first
      @calendar.calendar_events.create(title: event[:term], start_date: event[:start_date], end_date: event[:end_date], calendar_event_type: event_type, academic_year: academic_year)
    end

    create_bank_holidays
    create_dummy_inset_day
  end

private

  def create_dummy_inset_day
    @calendar.calendar_events.create(title: 'Insert Day', start_date: '2018-07-01', end_date: '2018-07-01', calendar_event_type: @inset_day_type, academic_year: AcademicYear.find_by(start_date: '01-09-2018'))
  end

  def create_bank_holidays
    find_bank_holidays(@area).each do |bh|
      calendar_event_type = CalendarEventType.find_by(description: bh.title)
      @calendar.calendar_events.create(title: bh.title, start_date: bh.holiday_date, end_date: bh.holiday_date, calendar_event_type: calendar_event_type)
    end
  end

  def find_bank_holidays(area)
    bhs = BankHoliday.where(area: area)
    return bhs if bhs.any?
    find_bank_holidays(area.parent_area)
  end


  def make_sure_calendar_event_types_created
    term_colour = 'rgb(245, 187, 0)'
    CalendarEventType.where(title: 'Term 1', description: 'Autumn Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 2', description: 'Autumn Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 3', description: 'Spring Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 4', description: 'Spring Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 5', description: 'Summer Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 6', description: 'Autumn Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create

    @inset_day_type = CalendarEventType.where(title: 'Inset Day', description: 'Training day', school_occupied: true, term_time: false, colour: 'rgb(255, 74, 50)').first_or_create

    BankHoliday.pluck(:title).uniq.each do |bh_title|
      CalendarEventType.where(title: 'Bank Holiday', description: bh_title, school_occupied: false, term_time: false, colour: 'rgb(255, 74, 50)').first_or_create
    end
  end
end

class CalendarFactory
  def initialize(event_hash, group, template = false)
    @event_hash = event_hash
    @group = group
    @template = template
  end

  def create
    @calendar = Calendar.where(default: @template, group: @group, title: @group.title, template: @template).first_or_create

    make_sure_calendar_event_types_created

    @event_hash.each do |event|
      event_type = CalendarEventType.select { |cet| event[:term].include? cet.title }.first
      @calendar.calendar_events.create(title: event[:term], start_date: event[:start_date], end_date: event[:end_date], calendar_event_type: event_type)
    end

    create_bank_holidays
  end

private

  def create_bank_holidays
    find_bank_holidays(@group).each do |bh|
      calendar_event_type = CalendarEventType.find_by(description: bh.title)
      @calendar.calendar_events.create(title: bh.title, start_date: bh.holiday_date, end_date: bh.holiday_date, calendar_event_type: calendar_event_type)
    end
  end

  def find_bank_holidays(group)
    pp "Looking for group #{group.title}"
    bhs = BankHoliday.where(group: group)
    pp bhs.any?
    return bhs if bhs.any?
    find_bank_holidays(group.parent_group)
  end


  def make_sure_calendar_event_types_created
    CalendarEventType.where(title: 'Term 1', description: 'Autumn Half Term 1', occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 2', description: 'Autumn Half Term 2', occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 3', description: 'Spring Half Term 1', occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 4', description: 'Spring Half Term 2', occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 5', description: 'Summer Half Term 1', occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 6', description: 'Autumn Half Term 2', occupied: true, term_time: true).first_or_create

    BankHoliday.pluck(:title).uniq.each do |bh_title|
      CalendarEventType.where(title: 'Bank Holiday', description: bh_title, occupied: false, term_time: false).first_or_create
    end
  end
end

class CalendarFactoryFromEventHash
  def initialize(event_hash, area, template = false)
    @event_hash = event_hash
    @area = area
    @template = template
  end

  def create
    @calendar = Calendar.where(default: @template, calendar_area: @area, title: @area.title, template: @template).first_or_create

    raise ArgumentError unless CalendarEventType.any?

    @event_hash.each do |event|
      event_type = CalendarEventType.select { |cet| event[:term].include? cet.title }.first
      raise ArgumentError if event_type.nil?

      academic_year = AcademicYear.where('start_date <= ? and end_date >= ?', Date.parse(event[:start_date]), Date.parse(event[:start_date])).first
      @calendar.calendar_events.where(title: event[:term], start_date: event[:start_date], end_date: event[:end_date], calendar_event_type: event_type, academic_year: academic_year).first_or_create!
    end

    create_bank_holidays
    create_holidays_between_terms
    @calendar
  end

private

  def create_holidays_between_terms
    HolidayFactory.new(@calendar).create
  end

  def create_bank_holidays
    calendar_event_type = CalendarEventType.bank_holiday.first
    find_bank_holidays(@area).each do |bh|
      @calendar.calendar_events.where(title: bh.title, start_date: bh.holiday_date, end_date: bh.holiday_date, calendar_event_type: calendar_event_type).first_or_create!
    end
  end

  def find_bank_holidays(area)
    bhs = BankHoliday.where(calendar_area: area)
    return bhs if bhs.any?
    find_bank_holidays(area.parent_area)
  end
end

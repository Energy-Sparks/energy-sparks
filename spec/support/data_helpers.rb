module EnergySparksDataHelpers
  def create_active_school(*args)
    create(:school, *args).tap do |school|
      template_calendar = create(:regional_calendar)
      school.template_calendar = template_calendar
      create :consent_grant, school: school
      school_creator = SchoolCreator.new(school)
      school_creator.process_new_school!
      school_creator.process_new_configuration!
      school_creator.make_visible!
    end
  end

  def create_all_calendar_events
    CalendarEventType.where(title: 'Term 1', description: 'Autumn Half Term 1', school_occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 2', description: 'Autumn Half Term 2', school_occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 3', description: 'Spring Half Term 1', school_occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 4', description: 'Spring Half Term 2', school_occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 5', description: 'Summer Half Term 1', school_occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 6', description: 'Autumn Half Term 2', school_occupied: true, term_time: true).first_or_create

    CalendarEventType.where(title: 'Holiday', description: 'Holiday', holiday: true, school_occupied: false, term_time: false, analytics_event_type: :school_holiday).first_or_create
    CalendarEventType.where(title: 'Bank Holiday', description: 'Bank Holiday', school_occupied: false, term_time: false, bank_holiday: true, holiday: false, analytics_event_type: :bank_holiday).first_or_create

    CalendarEventType.where(title: "In school #{CalendarEventType::INSET_DAY}", description: 'Training day in school', school_occupied: true, term_time: false, inset_day: true, analytics_event_type: :inset_day_in_school).first_or_create
    CalendarEventType.where(title: "Out of school #{CalendarEventType::INSET_DAY}", description: 'Training day out of school', school_occupied: false, term_time: false, inset_day: true, analytics_event_type: :inset_day_out_of_school).first_or_create

    CalendarEventType.all
  end

  def amr_data_feed_reading_to_s(meter, amr)
    # Sometimes the DB would return the timestamp with 5 digits of milisecond precision
    # i.e. it would return 1234.56789
    # whereas going through active record, would return 1234.567890
    # The gsub trims the trailing zero where appropriate
    formatted_date_time_stamp = amr.updated_at.strftime('%Y-%m-%d %H:%M:%S.%6N').gsub(/0+$/, '')
    "#{meter.school.urn},#{meter.school.name},#{meter.mpan_mprn},#{meter.meter_type.titleize},#{amr.reading_date},#{amr.amr_data_feed_import_log.amr_data_feed_config.date_format},#{formatted_date_time_stamp},#{amr.readings.join(',')}"
  end
end

RSpec.configure do |config|
  config.include EnergySparksDataHelpers
end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Calendar.create!( title: "Default Calendar", default: true )

# calendar = Calendar.create(title: 'BANES', default: true, start_year: 2017, end_year: 2018)
# term1 = CalendarEventType.create(title: 'Term 1', description: 'Autumn Half Term 1')
# term2 = CalendarEventType.create(title: 'Term 2', description: 'Autumn Half Term 2')
# term3 = CalendarEventType.create(title: 'Term 3', description: 'Spring Half Term 1')
# term4 = CalendarEventType.create(title: 'Term 4', description: 'Spring Half Term 2')
# term5 = CalendarEventType.create(title: 'Term 5', description: 'Summer Half Term 1')
# term6 = CalendarEventType.create(title: 'Term 6', description: 'Autumn Half Term 2')

# CalendarEvent.create(calendar: calendar, calendar_event_type: term1, start_date: '2017-09-04', end_date: '2017-10-20')
# CalendarEvent.create(calendar: calendar, calendar_event_type: term2, start_date: '2017-10-30', end_date: '2017-12-15')
# CalendarEvent.create(calendar: calendar, calendar_event_type: term3, start_date: '2018-01-02', end_date: '2018-02-09')
# CalendarEvent.create(calendar: calendar, calendar_event_type: term4, start_date: '2018-02-19', end_date: '2018-03-23')
# CalendarEvent.create(calendar: calendar, calendar_event_type: term5, start_date: '2018-04-09', end_date: '2018-05-25')
# CalendarEvent.create(calendar: calendar, calendar_event_type: term6, start_date: '2018-06-04', end_date: '2018-07-24')

# "2015-16 Term 1",2015-09-02,2015-10-21
# "2015-16 Term 2",2015-11-02,2015-12-18
# "2015-16 Term 3",2016-01-04,2016-02-12
# "2015-16 Term 4",2016-02-22,2016-04-01
# "2015-16 Term 5",2016-04-18,2016-05-27
# "2015-16 Term 6",2016-06-06,2016-07-19
# "2016-17 Term 1",2016-09-01,2016-10-21
# "2016-17 Term 2",2016-10-31,2016-12-16
# "2016-17 Term 3",2017-01-03,2017-02-10
# "2016-17 Term 4",2017-02-20,2017-04-07
# "2016-17 Term 5",2017-04-24,2017-05-26
# "2016-17 Term 6",2017-06-05,2017-07-21
# "2017-18 Term 1",2017-09-04,2017-10-20
# "2017-18 Term 2",2017-10-30,2017-12-15
# "2017-18 Term 3",2018-01-02,2018-02-09
# "2017-18 Term 4",2018-02-19,2018-03-23
# "2017-18 Term 5",2018-04-09,2018-05-25
# "2017-18 Term 6",2018-06-04,2018-07-24

# t.text    :description
# t.text    :alias
# t.boolean :term_time, default: true
# t.boolean :holiday,   default: false
# t.boolean :occupied,  default: true

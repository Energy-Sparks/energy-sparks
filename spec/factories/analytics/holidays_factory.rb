# frozen_string_literal: true

FactoryBot.define do
  factory :holidays, class: 'Holidays' do
    # Creates a holidays object populated with a typical set of school holidays for
    # a single calendar year. Dates in the data are based on 2023. The Holiday class
    # may adjust these to sat/sunday boundaries
    #
    # Doesn't add bank holidays or inset days
    trait :with_calendar_year do
      transient do
        country { nil }
        year    { Date.today.year }
      end

      initialize_with do
        data = HolidayData.new
        data.push(
          build(:holiday, name: 'Spring half term', start_date: Date.new(year, 2, 17), end_date: Date.new(year, 2, 19))
        )
        data.push(
          build(:holiday, name: 'Easter',
                          start_date: Date.new(year, 4, 1), end_date: Date.new(year, 4, 16))
        )
        data.push(
          build(:holiday, name: 'Summer half term',
                          start_date: Date.new(year, 5, 27), end_date: Date.new(year, 6, 4))
        )
        data.push(
          build(:holiday, name: 'Summer',
                          start_date: Date.new(year, 7, 22), end_date: Date.new(year, 8, 31))
        )
        data.push(
          build(:holiday, name: 'Autumn half term',
                          start_date: Date.new(year, 10, 21), end_date: Date.new(year, 10, 29))
        )
        data.push(
          build(:holiday, name: 'Xmas',
                          start_date: Date.new(year, 12, 16), end_date: Date.new(year + 1, 1, 1))
        )
        new(data, country)
      end
    end
  end
end

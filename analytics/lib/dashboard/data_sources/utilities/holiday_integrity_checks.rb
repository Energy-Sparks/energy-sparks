class Holidays
  def check_school_holidays(school)
    check_holidays(school, school.holidays, country: school.country)
  end

  def check_holidays(school, holidays, country: :default)
    rules = self.class.holiday_rules(country: country, funding_status: school.funding_status)
    [
      check_existing_holidays(school, holidays, rules),
      check_missing_holidays(holidays, country),
      check_number_of_holidays(school, holidays, rules)
    ].flatten
  end

  def school_holiday_exceptions(school, year)
    [
      -> { school.area_name == 'Sheffield'     && year == 2014 ? ({ weekdays: 62..72 }) : nil },
      -> { school.country == :wales            && year == 2019 ? ({ weekdays: 62..66 }) : nil },
      -> { school.country == :wales            && year == 2020 ? ({ weekdays: 67..74 }) : nil },
      -> { school.country == :wales            && year == 2020 ? ({ autumn_half_term: { weekdays:  5..10 } }) : nil },
      -> { school.country == :wales            && year == 2021 ? ({ weekdays: 66..72 }) : nil },
      -> { school.country == :wales            && year == 2021 ? ({ summer: { weekdays:  25..33 } }) : nil },
    ]
  end

  def self.school_holiday_configuration
    {
      default: {
        xmas:             { toy_range: TOY.new(12, 15)..TOY.new( 1,  8), weekdays:  8..12 },
        spring_half_term: { toy_range: TOY.new( 2,  5)..TOY.new( 3,  3), weekdays:  5..6  },
        easter:           { toy_range: TOY.new( 3, 19)..TOY.new( 4, 30), weekdays:  6..12 },
        summer_half_term: { toy_range: TOY.new( 5, 21)..TOY.new( 6, 10), weekdays:  5..6  },
        summer:           { toy_range: TOY.new( 7, 15)..TOY.new( 9,  6), weekdays: 25..32 },
        autumn_half_term: { toy_range: TOY.new(10, 16)..TOY.new(11,  7), weekdays:  5..7 },
        weekdays:         65..72
      },
      scotland: {
        spring_half_term: { toy_range: TOY.new( 2,  5)..TOY.new( 3,  1), weekdays:  4..6  },
        summer:           { toy_range: TOY.new( 6, 26)..TOY.new( 8, 20), weekdays: 25..35 },
        autumn_half_term: { toy_range: TOY.new(10,  7)..TOY.new(11,  1), weekdays:  5..10 },
        # summer_half_term - removed below as doesn't exist in Scotland
        weekdays:         63..72
      },
      england: {
      },
      wales: {
        weekdays:         65..70
      },
      private: {
        xmas:             { toy_range: TOY.new(12, 10)..TOY.new( 1, 10), weekdays:  8..17 },
        easter:           { toy_range: TOY.new( 3, 19)..TOY.new( 4, 30), weekdays:  6..16 },
        summer:           { toy_range: TOY.new( 7,  4)..TOY.new( 9,  6), weekdays: 35..45 },
        autumn_half_term: { toy_range: TOY.new(10, 16)..TOY.new(11,  7), weekdays:  5..10 },
        weekdays:         85..95
      }
    }
  end

  def academic_years2
    summer_holidays = holidays_of_type(:summer)
    summer_holidays = summer_holidays.select { |hol| hol.days > 20 }

    summer_holidays.map.with_index do |holiday, index|
      if index < summer_holidays.length - 1
        year = holiday.end_date.year
        SchoolDatePeriod.new(:academicyear, "#{year}/#{year + 1}", holiday.end_date + 1, summer_holidays[index + 1].end_date)
      else
        nil
      end
    end.compact
  end

  def holiday_days_in_period(period)
    (period.start_date..period.end_date).count do |date|
      holiday?(date)
    end
  end

  def holidays_of_type(holiday_type)
    holidays.select { |h| h.type == holiday_type }
  end

  def holiday_weekdays_in_period(period)
    (period.start_date..period.end_date).count do |date|
      holiday?(date) && date.wday.between?(1,5)
    end
  end

  private

  class TOY < TimeOfYear
    def to_toy
      TimeOfYear.new(self.month, self.day)
    end
  end

  def self.holiday_rules(country: :default, funding_status:)
    if funding_status == :private
      school_holiday_configuration[:default].merge(school_holiday_configuration[:private])
    elsif country == :scotland
      config = school_holiday_configuration[:default].merge(school_holiday_configuration[country])
      config.delete(:summer_half_term)
      config
    else
      school_holiday_configuration[:default].merge(school_holiday_configuration[country])
    end
  end

  def self.main_school_holiday_types(country)
    types = school_holiday_configuration[:default].keys
    types.delete(:summer_half_term) if country == :scotland
    types.delete(:weekdays)
    types
  end

  def apply_exception_to_rules(rules, school, year)
    exceptions = school_holiday_exceptions(school, year).map(&:call).compact
    unless exceptions.empty?
      rules = rules.deep_dup
      exceptions.each do |exception|
        rules.deep_merge!(exception)
      end
    end
    rules
  end

  def check_existing_holidays(school, holidays, rules)
    problems = []

    holidays.holidays.each do |holiday|
      rules = apply_exception_to_rules(rules, school, holiday.start_date.year)
      rule = rules[holiday.type].dup

      number_weekdays = holiday.number_weekdays

      next if number_weekdays <= 2

      if rules[holiday.type].nil?
        problems.push("Holiday #{holiday} of unknown type}")
        next
      end

      toy_range = rule[:toy_range].first.to_toy..rule[:toy_range].last.to_toy

      unless TOY.date_within_range(holiday.start_date, toy_range)
        problems.push("Holiday #{holiday} outside expected time of year range #{rule[:toy_range]}")
      end

      unless TOY.date_within_range(holiday.end_date, toy_range)
        problems.push("Holiday #{holiday} outside expected time of year range #{rule[:toy_range]}")
      end

      if number_weekdays < rule[:weekdays].first
        problems.push("Holiday #{holiday} of length #{number_weekdays} weekdays, unexpectedly short, expecting in range #{rule[:weekdays]}")
      end

      if number_weekdays > rule[:weekdays].last
        problems.push("Holiday #{holiday} of length #{number_weekdays} weekdays, unexpectedly long, expecting in range #{rule[:weekdays]}")
      end
    end

    problems
  end

  def check_number_of_holidays(school, holidays, rules)
    problems = []

    weekday_holidays_by_year = weekday_holidays_in_each_academic_year(holidays)

    weekday_holidays_by_year.each do |acc_year, weekdays|
      rules = apply_exception_to_rules(rules, school, acc_year.start_date.year)
      problems.push("Wrong number of holidays in #{acc_year.title} got #{weekdays} expecting within range #{rules[:weekdays]}") unless rules[:weekdays].cover?(weekdays)
    end

    problems
  end

  def weekday_holidays_in_each_academic_year(holidays)
    holidays.academic_years2.map do |acc_year|
      [
        acc_year,
        holidays.holiday_weekdays_in_period(acc_year)
      ]
    end.to_h
  end

  def holidays_academic_year(holidays, acc_year)
    holidays.holidays.select { |hol| hol.start_date >= acc_year.start_date && hol.end_date <= acc_year.end_date }
  end

  def check_missing_holidays(holidays, country)
    problems = []

    holidays.academic_years2.map do |acc_year|
      holidays_in_year = holidays_academic_year(holidays, acc_year)

      holiday_types_in_year = holidays_in_year.map(&:type)

      self.class.main_school_holiday_types(country).each do |type|
        unless holiday_types_in_year.include?(type)
          problems.push("Holiday type #{type} not set in academic year #{acc_year.title}")
        end
      end
    end

    problems
  end
end

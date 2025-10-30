FactoryBot.define do
  factory :school do
    sequence(:urn, 10_000)
    sequence(:number_of_pupils)
    sequence(:name, 'School AAAAA1')
    school_type     { :primary }
    funding_status  { :state_school }
    visible         { true }
    process_data    { true }
    data_enabled    { true }
    address         { '1 Station Road' }
    postcode        { 'AB1 2CD' }
    country         { :england }
    floor_area      { BigDecimal('1234.567')}
    website         { "http://#{name.camelize}.test" }
    calendar        { create(:school_calendar) }
    weather_station

    after(:build) do |school, _evaluator|
      build(:configuration, school: school)
    end

    factory :school_with_same_name do
      name { 'test school'}
    end

    trait :with_consent do
      after(:create) do |school, _evaluator|
        create(:consent_grant, school:)
      end
    end

    trait :with_school_group do
      transient do
        default_issues_admin_user { create(:admin) }
        school_group { nil }
      end

      after(:create) do |school, evaluator|
        group = evaluator.school_group || create(:school_group, default_issues_admin_user: evaluator.default_issues_admin_user)
        school.update(school_group: group)
      end
    end

    trait :with_school_grouping do
      transient do
        group_type { :multi_academy_trust }
        role { :organisation }
        school_group { nil }
      end

      after(:create) do |school, evaluator|
        group = evaluator.school_group || create(:school_group, group_type: evaluator.group_type)
        create(:school_grouping, school:, school_group: group, role: evaluator.role)
      end
    end

    trait :with_trust do
      with_school_grouping

      transient do
        group_type { :multi_academy_trust }
        role { :organisation }
      end
    end

    trait :with_diocese do
      with_school_grouping

      transient do
        group_type { :diocese }
        role { :area }
      end
    end

    trait :with_project do
      with_school_grouping

      transient do
        group_type { :project }
        role { :project }
      end
    end

    trait :with_scoreboard do
      after(:create) do |school, _evaluator|
        school.update(scoreboard: create(:scoreboard))
      end
    end

    trait :with_local_authority do
      after(:create) do |school, _evaluator|
        school.update(local_authority_area: create(:local_authority_area))
      end
    end

    trait :archived do
      active { false }
      removal_date { nil }
    end

    trait :deleted do
      active { false }
      removal_date { Date.new(2023, 1, 1) }
    end

    trait :with_calendar do
      after(:create) do |school, _evaluator|
        school.update(calendar: create(:school_calendar))
      end
    end

    trait :with_feed_areas do
      after(:create) do |school, _evaluator|
        school.update(dark_sky_area: create(:dark_sky_area), solar_pv_tuos_area: create(:solar_pv_tuos_area), weather_station: create(:weather_station))
      end
    end

    trait :with_points do
      transient do
        score_points { 1 }
        activities_happened_on { 1.month.ago }
      end

      after(:create) do |school, evaluator|
        activity_type = create(:activity_type, score: evaluator.score_points)
        create(:activity, school: school, activity_type: activity_type, happened_on: evaluator.activities_happened_on)
      end
    end

    trait :with_fuel_configuration do
      transient do
        has_electricity { true }
        has_gas { true }
        has_storage_heaters { true }
        has_solar_pv { true }
      end

      after(:create) do |school, evaluator|
        fuel_configuration = Schools::FuelConfiguration.new(
          has_electricity: evaluator.has_electricity,
          has_gas: evaluator.has_gas,
          has_storage_heaters: evaluator.has_storage_heaters,
          has_solar_pv: evaluator.has_solar_pv
        )
        school.configuration.update!(fuel_configuration: fuel_configuration)
      end
    end

    trait :with_meter_dates do
      transient do
        fuel_type { :electricity }
        reading_start_date { 1.year.ago }
        reading_end_date { Time.zone.today }
      end

      after(:create) do |school, evaluator|
        school.configuration.update!(
          aggregate_meter_dates: {
            evaluator.fuel_type => {
              start_date: evaluator.reading_start_date.iso8601,
              end_date: evaluator.reading_end_date.iso8601
            }
          }
        )
      end
    end

    # Creates a school with a school group, calendar, fuel configuration, single meter
    # and tariffs for that meter. Should be sufficient for passing to the analytics for
    # most analysis.
    #
    trait :with_basic_configuration_single_meter_and_tariffs do
      transient do
        fuel_type { :electricity }
        reading_start_date { 1.year.ago }
        reading_end_date { Time.zone.today }
        reading { 0.5 }
        tariff_start_date { nil }
        tariff_end_date { nil }
        calendar { nil }
      end
      with_school_group
      with_fuel_configuration
      with_meter_dates
      after(:create) do |school, evaluator|
        if evaluator.calendar
          school.update(calendar: evaluator.calendar)
        else
          calendar = create(:school_calendar, :with_terms_and_holidays, term_start_date: 1.year.ago)
          school.update(calendar: calendar)
        end
        create(:energy_tariff,
               :with_flat_price,
               tariff_holder: school,
               start_date: evaluator.tariff_start_date,
               end_date: evaluator.tariff_end_date,
               meter_type: evaluator.fuel_type)
        if evaluator.fuel_type == :electricity
          create(:electricity_meter_with_validated_reading_dates,
                 school: school,
                 start_date: evaluator.reading_start_date,
                 end_date: evaluator.reading_end_date,
                 reading: evaluator.reading)
        else
          create(:gas_meter_with_validated_reading_dates,
                 school: school,
                 start_date: evaluator.reading_start_date,
                 end_date: evaluator.reading_end_date,
                 reading: evaluator.reading)
        end
        school
      end
    end
  end
end

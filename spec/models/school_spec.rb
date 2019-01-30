require 'rails_helper'

describe School do

  let(:today) { Time.zone.today }
  let(:calendar) { create :calendar_with_terms, template: true }
  subject { create :school, calendar: calendar }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'builds a slug on create using :name' do
    expect(subject.slug).to eq(subject.name.parameterize)
  end

  describe 'knows whether the school is open or not' do
    pending 'when open close times are defined' do
      SchoolTime.days.each do |day, _value|
        # default values
        subject.school_times.create(day: day)
      end
      subject.school_times.tuesday.update(opening_time: 1100, closing_time: 1500)

      monday_open = DateTime.parse("2018-07-16T11:00:00")
      monday_closed = DateTime.parse("2018-07-16T07:00:00")
      tuesday_open = DateTime.parse("2018-07-17T13:00:00")
      tuesday_closed = DateTime.parse("2018-07-17T18:00:00")
      saturday_closed = DateTime.parse("2018-07-14T18:00:00")
      sunday_closed = DateTime.parse("2018-07-15T18:00:00")

      expect(subject.is_open?(monday_open)).to be true
      expect(subject.is_open?(monday_closed)).to be false
      expect(subject.is_open?(tuesday_open)).to be true
      expect(subject.is_open?(tuesday_closed)).to be false
      expect(subject.is_open?(saturday_closed)).to be false
      expect(subject.is_open?(sunday_closed)).to be false
    end
  end

  describe 'FriendlyID#slug_candidates' do
    context 'when two schools have the same name' do
      it 'builds a different slug using :postcode and :name' do
        school = (create_list :school_with_same_name, 2).last
        expect(school.slug).to eq([school.postcode, school.name].join('-').parameterize)
      end
    end
    context 'when three schools have the same name and postcode' do
      it 'builds a different slug using :urn and :name' do
        school = (create_list :school_with_same_name, 3).last
        expect(school.slug).to eq([school.urn, school.name].join('-').parameterize)
      end
    end
  end

  describe '#meters?' do
    context 'when the school has meters of type :gas' do
      it 'returns true' do
        create :gas_meter_with_reading, school_id: subject.id
        expect(subject.meters?(:gas)).to be(true)
      end
    end
    context 'when the school has no meters' do
      it 'returns false' do
        expect(subject.meters?(:gas)).to be(false)
      end
    end
  end

  describe '#alert_subscriptions?' do
    context 'when any alerts are set up for the school' do
      it 'returns true' do
        alert_type = create :alert_type
        contact = create :contact, :with_email_address, school_id: subject.id
        alert = AlertSubscription.create(alert_type: alert_type, school: subject, contacts: [contact])
        expect(subject.contacts.count).to be 1
        expect(subject.alert_subscriptions.count).to be 1
        expect(subject.contacts.first.alert_subscriptions.first).to eq alert
        expect(subject.alert_subscriptions?).to be true
      end
    end
    context 'when no alert subscriptions are set up for the school' do
      it 'returns false' do
        expect(subject.alert_subscriptions?).to be false
      end
    end
  end

  describe "knows whether the previous week has a full amount of readings" do
    let(:end_date) { Time.zone.today.prev_occurring(:saturday) }
    let(:start_date) { end_date - 8.days }

    it 'no readings' do
      meter_one = create(:gas_meter, school: subject)
      meter_two = create(:electricity_meter, school: subject)

      expect(subject.has_last_full_week_of_readings?).to be false
    end

    it 'some readings' do
      meter_one = create(:gas_meter, school: subject)
      meter_two = create(:electricity_meter, school: subject)

      start_date = end_date - 1.day

      (start_date..end_date).each do |date|
        create(:amr_validated_reading, meter: meter_one, reading_date: date)
      end
      expect(subject.meters.first.amr_validated_readings.size).to be 2
      expect(subject.has_last_full_week_of_readings?).to be false
    end

    it 'all readings' do
      meter_one = create(:gas_meter, school: subject)
      meter_two = create(:electricity_meter, school: subject)

      (start_date..end_date).each do |date|
        create(:amr_validated_reading, meter: meter_one, reading_date: date)
        create(:amr_validated_reading, meter: meter_two, reading_date: date)
      end

      expect(subject.meters.first.amr_validated_readings.size).to be 9
      expect(subject.meters.second.amr_validated_readings.size).to be 9
      expect(subject.has_last_full_week_of_readings?).to be true
    end

    it 'ignore inactive meters' do
      meter_one = create(:gas_meter, school: subject)
      meter_two = create(:electricity_meter, school: subject, active: false)

      (start_date..end_date).each do |date|
        create(:amr_validated_reading, meter: meter_one, reading_date: date)
      end
      expect(subject.meters.first.amr_validated_readings.size).to be 9
      expect(subject.has_last_full_week_of_readings?).to be true
    end
  end

  describe '#current_term' do

    it 'returns the current term' do
      current_term = create :term, calendar_id: subject.calendar_id, start_date: today.months_ago(3), end_date: today.tomorrow
      expect(subject.current_term).to eq(current_term)
    end
  end

  describe '#last_term' do

    it 'returns the term preceeding #current_term' do
      create :term, calendar_id: subject.calendar_id, start_date: today.months_ago(3), end_date: today.tomorrow
      last_term = create :term, calendar_id: subject.calendar_id, start_date: today.months_ago(6), end_date: today.yesterday.months_ago(3)

      expect(subject.last_term).to eq(last_term)
    end
  end

  describe '#badges_by_date' do
    it 'returns an array of badges ordered by date' do
      badge = create :badge
      badges_sash = (1..5).collect { |n| create :badges_sash, badge_id: badge.id, sash_id: subject.sash_id, created_at: today.days_ago(n) }

      expect(subject.badges_by_date).to eq(
        badges_sash
          .sort { |x, y| x.created_at <=> y.created_at }
          .map(&:badge)
      )
    end
  end

  describe '.top_scored' do
    let(:score) { create :score, sash_id: subject.sash_id }

    context 'when no limit is provided' do
      it 'returns an array of schools ordered by points' do
        schools = (1..5).collect { |n| create :school, :with_points, score_points: 6 - n }

        expect(School.top_scored.map(&:id)).to eq(schools.map(&:id))
      end
    end
    context 'when a limit is provided' do
      it 'returns an array of schools ordered by points of length no longer than limit' do
        schools = (1..8).collect { |n| create :school, :with_points, score_points: 8 - n }

        expect(School.top_scored(limit: 5).map(&:id)).to eq(schools[0..4].map(&:id))
      end
    end
    context 'when no date range is provided' do
      it 'limits points counted to those awarded since the start of the academic year' do
        schools = (1..5).collect { |n| create :school, :with_points, score_points: 6 - n }
        create :score_point, score_id: score.id, created_at: today.years_ago(2), num_points: 100

        expect(School.top_scored.map(&:id)).to eq(schools.map(&:id))
      end
    end
    context 'when a date range is provided' do
      it 'limits points counted to those awarded in the date range' do
        schools = (1..5).collect { |n| create :school, :with_points, score_points: 6 - n }
        create :score_point, score_id: score.id, created_at: today.years_ago(2), num_points: 100

        expect(School.top_scored(dates: today.months_ago(1)..today.tomorrow).map(&:id)).to eq(schools.map(&:id))
      end
    end
  end

  describe '#fuel_types' do
    it 'identifies dual fuel if it has both meters' do
      gas_meter = create(:gas_meter_with_reading, school: subject)
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      expect(subject.fuel_types).to eq :electric_and_gas
    end

    it 'identifies electricity if it has electricity only' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      expect(subject.fuel_types).to eq :electric_only
    end

    it 'identifies gas if it has gas only' do
      gas_meter = create(:gas_meter_with_reading, school: subject)
      expect(subject.fuel_types).to eq :gas_only
    end

    it 'identifies gas if it has gas only with no readings for electricity' do
      electricity_meter = create(:electricity_meter, school: subject)
      gas_meter = create(:gas_meter_with_reading, school: subject)
      expect(subject.fuel_types).to eq :gas_only
    end

    it 'identifies gas if it has gas only with readings and one without and no readings for electricity' do
      electricity_meter = create(:electricity_meter, school: subject)
      gas_meter = create(:gas_meter_with_reading, school: subject)
      gas_meter_no_readings = create(:gas_meter, school: subject)
      expect(subject.fuel_types).to eq :gas_only
    end

    it 'identifies electricity if it has an electricity with readings and with no readings for gas' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      gas_meter = create(:gas_meter, school: subject)
      expect(subject.fuel_types).to eq :electric_only
    end

    it 'identifies electricity if it has an electricity with readings and one without and with no readings for gas' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      electricity_meter_no_readings = create(:electricity_meter, school: subject)
      gas_meter = create(:gas_meter, school: subject)
      expect(subject.fuel_types).to eq :electric_only
    end
  end

  describe '#meters_with_readings' do
    it 'works if explicitly giving a supply type of electricity' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      expect(subject.meters_with_readings(:electricity).first).to eq electricity_meter
      expect(subject.meters_with_readings(:gas)).to be_empty
    end

    it 'works if explicitly giving a supply type of gas' do
      gas_meter = create(:gas_meter_with_reading, school: subject)
      expect(subject.meters_with_readings(:gas).first).to eq gas_meter
      expect(subject.meters_with_readings(:electricity)).to be_empty
    end

    it 'works without a supply type for a gas meter' do
      gas_meter = create(:gas_meter_with_reading, school: subject)
      expect(subject.meters_with_readings.first).to eq gas_meter
    end

    it 'works without a supply type for an electricity' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      expect(subject.meters_with_readings.first).to eq electricity_meter
    end
  end

  describe '#meters_with_validated_readings' do
    it 'works if explicitly giving a supply type of electricity' do
      electricity_meter = create(:electricity_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings(:electricity).first).to eq electricity_meter
      expect(subject.meters_with_validated_readings(:gas)).to be_empty
    end

    it 'works if explicitly giving a supply type of gas' do
      gas_meter = create(:gas_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings(:gas).first).to eq gas_meter
      expect(subject.meters_with_validated_readings(:electricity)).to be_empty
    end

    it 'works without a supply type for a gas meter' do
      gas_meter = create(:gas_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings.first).to eq gas_meter
    end

    it 'works without a supply type for an electricity' do
      electricity_meter = create(:electricity_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings.first).to eq electricity_meter
    end
  end

  describe '#has_enough_readings_for_meter_types?' do
    it 'does for electricity' do
      meter = create(:electricity_meter_with_validated_reading, reading_count: 3)
      expect(meter.school.has_enough_readings_for_meter_types?(:electricity, 2)).to be true
    end

    it 'does not for electricity' do
      meter = create(:electricity_meter_with_validated_reading, reading_count: 1)
      expect(meter.school.has_enough_readings_for_meter_types?(:electricity, 2)).to be false
    end

    it 'does not with no readings for electricity' do
      meter = create(:electricity_meter)
      expect(meter.school.has_enough_readings_for_meter_types?(:electricity, 1)).to be false
    end
  end

  describe '#fuel_types_for_analysis?' do
    it 'gas and electricity' do
      meter = create(:electricity_meter_with_validated_reading, school: subject, reading_count: 2)
      meter2 = create(:gas_meter_with_validated_reading, school: subject, reading_count: 2)
      expect(subject.fuel_types_for_analysis(1)).to be :electric_and_gas
    end

    it 'electricity' do
      meter = create(:electricity_meter_with_validated_reading, school: subject, reading_count: 2)
      expect(subject.fuel_types_for_analysis(1)).to be :electric_only
    end

    it 'gas' do
      meter = create(:gas_meter_with_validated_reading, school: subject, reading_count: 2)
      expect(subject.fuel_types_for_analysis(1)).to be :gas_only
    end

    it 'neither' do
      meter = create(:electricity_meter_with_validated_reading)
      meter = create(:gas_meter_with_validated_reading)
      expect(subject.fuel_types_for_analysis(5)).to be :none
    end
  end
end

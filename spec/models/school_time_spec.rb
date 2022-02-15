require 'rails_helper'

describe 'SchoolTime' do

  let(:school)      { create(:school) }

  context 'basic validation' do
    it 'allows valid objects' do
      expect(school.school_times.build(opening_time: 800, closing_time: 1600)).to be_valid
    end

    it 'requires both times' do
      expect(school.school_times.build(opening_time: nil)).to_not be_valid
      expect(school.school_times.build(closing_time: nil)).to_not be_valid
    end

    it 'validates as 24 hour time range' do
      expect(school.school_times.build(opening_time: -1)).to_not be_valid
      expect(school.school_times.build(closing_time: 2361)).to_not be_valid
    end
  end

  context '#to_analytics' do
    let!(:morning_time) { create(:school_time, school: school, day: :tuesday, usage_type: :community_use, opening_time: 700, closing_time: 830)}

    let!(:evening_time) { create(:school_time, school: school, day: :monday, usage_type: :community_use, opening_time: 1800, closing_time: 2030)}

    it 'serialises mornings correctly' do
      result = morning_time.to_analytics
      expect(result[:usage_type]).to eql :community_use
      expect(result[:day]).to eql :tuesday
      expect(result[:opening_time]).to eql TimeOfDay.new(7,0)
      expect(result[:closing_time]).to eql TimeOfDay.new(8,30)
      expect(result[:calendar_period]).to eql :term_time
    end

    it 'serialises evening correctly' do
      result = evening_time.to_analytics
      expect(result[:usage_type]).to eql :community_use
      expect(result[:day]).to eql :monday
      expect(result[:opening_time]).to eql TimeOfDay.new(18,0)
      expect(result[:closing_time]).to eql TimeOfDay.new(20,30)
      expect(result[:calendar_period]).to eql :term_time
    end
  end

  context 'with community usage' do
    it 'defaults to empty values' do
      time = school.school_times.build(usage_type: :school_day)
      expect(time.opening_time).to eql 850
      expect(time.closing_time).to eql 1520

      time = school.school_times.build(usage_type: :community_use)
      expect(time.opening_time).to be_nil
      expect(time.closing_time).to be_nil
    end
  end

  it 'should not allow multiple school days for a school' do
    school.school_times.create!(day: :monday)
    more_monday = school.school_times.create(day: :monday)
    expect(more_monday).to_not be_valid
  end

  it 'should require that a school day is a named day' do
    [:weekdays, :weekends, :everyday].each do |range|
      expect(school.school_times.create(day: range)).to_not be_valid
    end
  end

  it 'should require that a school day is term time only' do
    expect(school.school_times.create(day: :monday, calendar_period: :term_time)).to be_valid
    [:only_holidays, :all_year].each do |period|
      expect(school.school_times.create(day: :monday, calendar_period: period)).to_not be_valid
    end
  end

  #invalid:
  #term_time, school_use, monday 8-10, community_use, 9-10 no overlaps with school day
  #term_time, monday 8-10, monday 9-10 no overlaps on same day
  #term_time, monday 8-10, weekdays: 9-10, etc, no overlaps with ranges

  #valid:
  #term_time, monday 8-10
  #holidays_only, monday 9-10
  context 'when validating overlaps' do
    context 'of community use' do
      let!(:day)              { :monday }
      let!(:usage_type)       { :community_use }
      let!(:calendar_period)  { :term_time }
      let!(:opening_time)     { 800 }
      let!(:closing_time)     { 1200 }

      let!(:time)  { create(:school_time, school: school, day: day, usage_type: usage_type,
        calendar_period: calendar_period, opening_time: opening_time, closing_time: closing_time)}

      context 'ranges' do
        it 'checks all ranges' do
          #13-14, no overlap. OK
          expect( school.school_times.create(day: day, usage_type: :community_use, opening_time: 1300, closing_time: 1400) ).to be_valid
          #7-10, overlapping first part of range
          expect( school.school_times.create(day: day, usage_type: :community_use, opening_time: 700, closing_time: 1000) ).to_not be_valid
          #9-1, overlapping second part
          expect( school.school_times.create(day: day, usage_type: :community_use, opening_time: 900, closing_time: 1300) ).to_not be_valid
          #8-12, identical
          expect( school.school_times.create(day: day, usage_type: :community_use, opening_time: 800, closing_time: 1200) ).to_not be_valid
          #7-2, longer period
          expect( school.school_times.create(day: day, usage_type: :community_use, opening_time: 700, closing_time: 1400) ).to_not be_valid
        end
        it 'allows same times on different days' do
          expect( school.school_times.create(day: :tuesday, usage_type: :community_use, opening_time: 700, closing_time: 1000) ).to be_valid
        end
        it 'allows same times on different calendar period' do
          expect( school.school_times.create(day: day, calendar_period: :holidays_only, usage_type: :community_use, opening_time: 700, closing_time: 1000) ).to_not be_valid
        end
      end

      context 'and school day' do
        let(:usage_type) { :school_day }
        it 'should not allow overlaps' do
          #13-14, no overlap. OK
          expect( school.school_times.create(day: day, usage_type: :community_use, opening_time: 1300, closing_time: 1400) ).to be_valid
          #7-10, overlapping first part of range
          expect( school.school_times.create(day: day, usage_type: :community_use, opening_time: 700, closing_time: 1000) ).to_not be_valid
          #9-1, overlapping second part
          expect( school.school_times.create(day: day, usage_type: :community_use, opening_time: 900, closing_time: 1300) ).to_not be_valid
          #8-12, identical
          expect( school.school_times.create(day: day, usage_type: :community_use, opening_time: 800, closing_time: 1200) ).to_not be_valid
          #7-2, longer period
          expect( school.school_times.create(day: day, usage_type: :community_use, opening_time: 700, closing_time: 1400) ).to_not be_valid
        end
      end

      context 'named days and ranges' do
        let(:day) { :weekdays }
        it 'should not allow named ranges and named days to overlap' do
          #week day and weekends dont overlap
          expect( school.school_times.create(day: :saturday, usage_type: :community_use, opening_time: 1300, closing_time: 1400) ).to be_valid
          #week day and weekends dont overlap
          expect( school.school_times.create(day: :weekends, usage_type: :community_use, opening_time: 1300, closing_time: 1400) ).to be_valid
          #830-1230, mondays, overlaps with the week day range
          expect( school.school_times.create(day: :monday, usage_type: :community_use, opening_time: 830, closing_time: 1230) ).to_not be_valid
          #830-1230, everyday, overlaps with the week day range
          expect( school.school_times.create(day: :everyday, usage_type: :community_use, opening_time: 830, closing_time: 1230) ).to_not be_valid
        end
      end

      it 'should check across terms, holidays, etc'

    end
  end

end

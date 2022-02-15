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

  context 'with community usage' do
    it 'defaults to times in the evening' do
      time = school.school_times.build(usage_type: :school_day)
      expect(time.opening_time).to eql 850
      expect(time.closing_time).to eql 1520

      time = school.school_times.build(usage_type: :community_use)
      expect(time.opening_time).to eql 1800
      expect(time.closing_time).to eql 2000
    end

  end

  context 'with multiple times' do
    let(:day)   {:monday}
    let(:other_day) {:tuesday}

    let!(:first) { create(:school_time, school: school, day: day, usage_type: :community_use, opening_time: 1200, closing_time: 1300)}

    let(:second) { create(:school_time, school: school, day: other_day, usage_type: :community_use, opening_time: 1210, closing_time: 1310)}

    context 'on different days' do
      it 'allows them to overlap' do
        expect(second).to be_valid
      end
    end

    context 'on same day' do
      let(:other_day) { :monday }
      it 'ensures they dont overlap' do
        expect(second).to_not be_valid
      end
    end
  end

  context '#to_analytics' do
    let!(:morning_time) { create(:school_time, school: school, day: :tuesday, usage_type: :community_use, opening_time: 700, closing_time: 830, term_time_only: false)}

    let!(:evening_time) { create(:school_time, school: school, day: :monday, usage_type: :community_use, opening_time: 1800, closing_time: 2030)}

    it 'serialises mornings correctly' do
      result = morning_time.to_analytics
      expect(result[:usage_type]).to eql :community_use
      expect(result[:day]).to eql :tuesday
      expect(result[:opening_time]).to eql TimeOfDay.new(7,0)
      expect(result[:closing_time]).to eql TimeOfDay.new(8,30)
      expect(result[:term_time_only]).to eql false
    end

    it 'serialises evening correctly' do
      result = evening_time.to_analytics
      expect(result[:usage_type]).to eql :community_use
      expect(result[:day]).to eql :monday
      expect(result[:opening_time]).to eql TimeOfDay.new(18,0)
      expect(result[:closing_time]).to eql TimeOfDay.new(20,30)
      expect(result[:term_time_only]).to eql true
    end
  end
end

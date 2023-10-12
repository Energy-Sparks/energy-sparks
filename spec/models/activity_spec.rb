require 'rails_helper'

describe 'Activity' do
  describe '#between' do
    let!(:activity_1) { create(:activity, happened_on: '2020-02-01') }
    let!(:activity_2) { create(:activity, happened_on: '2020-03-01') }
    let!(:activity_3) { create(:activity, happened_on: '2020-04-01') }

    it 'returns ranges of activities' do
      expect(Activity.between('2020-01-01', '2020-01-31')).to match_array([])
      expect(Activity.between('2020-01-01', '2020-02-01')).to match_array([activity_1])
      expect(Activity.between('2020-01-01', '2020-03-31')).to match_array([activity_1, activity_2])
      expect(Activity.between('2020-01-01', '2020-04-01')).to match_array([activity_1, activity_2, activity_3])
    end
  end

  describe '#recorded_in_last_week' do
    let(:activity_too_old)      { create(:activity) }
    let(:activity_last_week_1)  { create(:activity) }
    let(:activity_last_week_2)  { create(:activity) }

    before do
      activity_too_old.update!(created_at: (7.days.ago - 1.minute))
      activity_last_week_1.update!(created_at: (7.days.ago + 1.minute))
      activity_last_week_2.update!(created_at: 1.minute.ago)
    end

    it 'excludes older activities' do
      expect(Activity.recorded_in_last_week).to match_array([activity_last_week_1, activity_last_week_2])
    end
  end
end

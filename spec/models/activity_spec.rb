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

  describe 'Callbacks' do
    shared_examples 'an observation with changes' do
      it 'updates updated_at timestamp' do
        expect(observation.updated_at).to be > observation.created_at
      end
    end

    shared_examples 'an observation without changes' do
      it 'does not update updated_at timestamp' do
        expect(observation.updated_at).to eq(observation.created_at)
      end
    end

    let!(:activity) { create(:activity, happened_on: Date.new(2025, 10, 5)).reload } # also creates observation
    let(:observation) { activity.observations.first.reload }

    context 'when updating happened_on' do
      before do
        # step forward in time 1 day to ensure updated_at changes
        travel 1.day do
          activity.update(happened_on: Date.new(2025, 10, 7))
        end
      end

      it 'updates associated observation at date' do
        expect(observation.at.to_date).to eq(Date.new(2025, 10, 7))
      end

      it_behaves_like 'an observation with changes'
    end

    context 'when updating description with image' do
      before do
        # step forward in time 1 day to ensure updated_at changes
        travel 1.day do
          activity.update(description: 'New description with <figure')
        end
      end

      it_behaves_like 'an observation with changes'
    end

    context 'when updating description without image' do
      before do
        # step forward in time 1 day to ensure updated_at changes
        travel 1.day do
          activity.update(description: 'New description without points')
        end
      end

      it_behaves_like 'an observation without changes'
    end

    context 'when updating fields other than happened on or description' do
      before do
        # step forward in time 1 day to ensure updated_at changes
        travel 1.day do
          activity.update(title: 'New title')
        end
      end

      it 'does not update associated observation at date' do
        expect(observation.at.to_date).to eq(Date.new(2025, 10, 5))
      end

      it_behaves_like 'an observation without changes'
    end
  end
end

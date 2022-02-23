require 'rails_helper'

describe 'ActivityType' do

  subject { create :activity_type }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid with invalid attributes' do
    type = build :activity_type, score: -1
    expect( type ).to_not be_valid
    expect( type.errors[:score] ).to include('must be greater than or equal to 0')
  end

  it 'applies live data scope via category' do
    activity_type_1 = create(:activity_type, activity_category: create(:activity_category, live_data: true))
    activity_type_2 = create(:activity_type, activity_category: create(:activity_category, live_data: false))
    expect( ActivityType.live_data ).to match_array([activity_type_1])
  end

  context 'search by query term' do
    it 'finds activities by name' do
      activity_type_1 =  create(:activity_type, name: 'foo')
      activity_type_2 =  create(:activity_type, name: 'bar')

      expect(ActivityType.search('foo')).to eq([activity_type_1])
      expect(ActivityType.search('bar')).to eq([activity_type_2])
    end
  end

  context 'scoped by key stage' do
    it 'filters activities by key stage' do
      key_stage_1 = create(:key_stage)
      key_stage_2 = create(:key_stage)
      activity_type_1 =  create(:activity_type, name: 'KeyStage One', key_stages: [key_stage_1])
      activity_type_2 =  create(:activity_type, name: 'KeyStage Two', key_stages: [key_stage_2])
      activity_type_3 =  create(:activity_type, name: 'KeyStage One and Two', key_stages: [key_stage_1, key_stage_2])

      expect(ActivityType.for_key_stages([key_stage_1])).to match_array([activity_type_1, activity_type_3])
    end

    it 'does not return duplicates' do
      key_stage_1 = create(:key_stage)
      key_stage_2 = create(:key_stage)
      activity_type_1 =  create(:activity_type, name: 'foo one', key_stages: [key_stage_1, key_stage_2])

      expect(ActivityType.for_key_stages([key_stage_1, key_stage_2]).count).to eq(1)
    end
  end

  context 'scoped by subject' do
    it 'filters activities by subject' do
      subject_1 = create(:subject)
      subject_2 = create(:subject)
      activity_type_1 =  create(:activity_type, name: 'KeyStage One', subjects: [subject_1])
      activity_type_2 =  create(:activity_type, name: 'KeyStage Two', subjects: [subject_2])
      activity_type_3 =  create(:activity_type, name: 'KeyStage One and Two', subjects: [subject_1, subject_2])

      expect(ActivityType.for_subjects([subject_1])).to match_array([activity_type_1, activity_type_3])
    end

    it 'does not return duplicates' do
      subject_1 = create(:subject)
      subject_2 = create(:subject)
      activity_type_1 =  create(:activity_type, name: 'foo one', subjects: [subject_1, subject_2])

      expect(ActivityType.for_subjects([subject_1, subject_2]).count).to eq(1)
    end
  end
end

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

  context 'scoped by key stage' do
    it 'filters activities by key stage' do
      key_stage_1 = create(:key_stage, name: 'KeyStage1')
      key_stage_2 = create(:key_stage, name: 'KeyStage2')
      activity_type_1 =  create(:activity_type, name: 'KeyStage One', key_stages: [key_stage_1])
      activity_type_2 =  create(:activity_type, name: 'KeyStage Two', key_stages: [key_stage_2])
      activity_type_3 =  create(:activity_type, name: 'KeyStage One and Two', key_stages: [key_stage_1, key_stage_2])

      expect(ActivityType.for_key_stages([key_stage_1])).to match_array([activity_type_1, activity_type_3])
      expect(ActivityType.for_key_stages([key_stage_1]).search('KeyStage')).to match_array([activity_type_1, activity_type_3])
    end
  end

  context '#search' do
    it 'finds activities by name' do
      activity_type_1 =  create(:activity_type, name: 'foo')
      activity_type_2 =  create(:activity_type, name: 'bar')

      expect(ActivityType.search('foo')).to eq([activity_type_1])
      expect(ActivityType.search('bar')).to eq([activity_type_2])
    end

    it 'finds activities by description' do
      activity_type_1 =  create(:activity_type, description: 'foo')
      activity_type_2 =  create(:activity_type, description: 'bar')

      expect(ActivityType.search('foo')).to eq([activity_type_1])
      expect(ActivityType.search('bar')).to eq([activity_type_2])
    end

    it 'must match all words' do
      activity_type_1 =  create(:activity_type, description: 'foo baz')
      activity_type_2 =  create(:activity_type, description: 'bar baz')

      expect(ActivityType.search('foo bar')).to eq([])
      expect(ActivityType.search('foo baz')).to eq([activity_type_1])
      expect(ActivityType.search('baz')).to eq([activity_type_1, activity_type_2])
    end

    it 'ignores school specific description' do
      activity_type_1 =  create(:activity_type, description: 'foo', school_specific_description: 'foo bar')
      activity_type_2 =  create(:activity_type, description: 'bar', school_specific_description: 'foo bar')

      expect(ActivityType.search('foo')).to eq([activity_type_1])
      expect(ActivityType.search('bar')).to eq([activity_type_2])
    end

    it 'ignores simple words' do
      activity_type_1 =  create(:activity_type, name: 'foo and the stuff')
      activity_type_2 =  create(:activity_type, name: 'bar and a thing')

      expect(ActivityType.search('and')).to eq([])
      expect(ActivityType.search('the')).to eq([])
      expect(ActivityType.search('a')).to eq([])
    end

    it 'ignores html markup' do
      activity_type_1 =  create(:activity_type, description: '<div>foo</div>')
      activity_type_2 =  create(:activity_type, description: '<div>bar</div>')

      expect(ActivityType.search('div')).to eq([])
      expect(ActivityType.search('<div>')).to eq([])
      expect(ActivityType.search('class')).to eq([])
      expect(ActivityType.search('foo')).to eq([activity_type_1])
      expect(ActivityType.search('bar')).to eq([activity_type_2])
    end

    it 'matches plurals' do
      activity_type_1 =  create(:activity_type, name: 'a thing')
      activity_type_2 =  create(:activity_type, name: 'some things')

      expect(ActivityType.search('thing')).to eq([activity_type_1, activity_type_2])
      expect(ActivityType.search('things')).to eq([activity_type_1, activity_type_2])
    end

    it 'does not match parts of words' do
      activity_type_1 =  create(:activity_type, name: 'petrol')
      activity_type_2 =  create(:activity_type, name: 'petroleum')

      expect(ActivityType.search('petrol')).to eq([activity_type_1])
    end
  end
end

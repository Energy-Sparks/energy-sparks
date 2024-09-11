require 'rails_helper'

describe ActivityTypeSearchService do
  before { ActivityType.delete_all }

  context 'search by query term' do
    it 'finds activities by name' do
      activity_type_1 = create(:activity_type, name: 'foo')
      activity_type_2 = create(:activity_type, name: 'bar')

      expect(ActivityTypeSearchService.search('foo')).to eq([activity_type_1])
      expect(ActivityTypeSearchService.search('bar')).to eq([activity_type_2])
    end

    it 'only finds active activity types' do
      create(:activity_type, name: 'foo baz', active: false)
      activity_type_2 = create(:activity_type, name: 'bar baz')

      expect(ActivityTypeSearchService.search('baz')).to eq([activity_type_2])
    end

    it 'finds activities by description' do
      activity_type_1 = create(:activity_type, description: 'foo')
      activity_type_2 = create(:activity_type, description: 'bar')

      expect(ActivityTypeSearchService.search('foo')).to eq([activity_type_1])
      expect(ActivityTypeSearchService.search('bar')).to eq([activity_type_2])
    end

    it 'must match all words' do
      activity_type_1 = create(:activity_type, description: 'foo baz')
      activity_type_2 = create(:activity_type, description: 'bar baz')

      expect(ActivityTypeSearchService.search('foo bar')).to eq([])
      expect(ActivityTypeSearchService.search('foo baz')).to eq([activity_type_1])
      expect(ActivityTypeSearchService.search('baz')).to match_array([activity_type_1, activity_type_2])
    end

    it 'ignores school specific description' do
      activity_type_1 = create(:activity_type, description: 'foo', school_specific_description: 'foo bar')
      activity_type_2 = create(:activity_type, description: 'bar', school_specific_description: 'foo bar')

      expect(ActivityTypeSearchService.search('foo')).to eq([activity_type_1])
      expect(ActivityTypeSearchService.search('bar')).to eq([activity_type_2])
    end

    it 'ignores simple words' do
      create(:activity_type, name: 'foo and the stuff')
      create(:activity_type, name: 'bar and a thing')

      expect(ActivityTypeSearchService.search('and')).to eq([])
      expect(ActivityTypeSearchService.search('the')).to eq([])
      expect(ActivityTypeSearchService.search('a')).to eq([])
    end

    it 'ignores html markup' do
      activity_type_1 = create(:activity_type, description: '<div>foo</div>')
      activity_type_2 = create(:activity_type, description: '<div>bar</div>')

      expect(ActivityTypeSearchService.search('div')).to eq([])
      expect(ActivityTypeSearchService.search('<div>')).to eq([])
      expect(ActivityTypeSearchService.search('class')).to eq([])
      expect(ActivityTypeSearchService.search('foo')).to eq([activity_type_1])
      expect(ActivityTypeSearchService.search('bar')).to eq([activity_type_2])
    end

    it 'matches plurals' do
      activity_type_1 = create(:activity_type, name: 'a thing')
      activity_type_2 = create(:activity_type, name: 'some things')

      expect(ActivityTypeSearchService.search('thing')).to match_array([activity_type_1, activity_type_2])
      expect(ActivityTypeSearchService.search('things')).to match_array([activity_type_1, activity_type_2])
    end

    it 'does not match parts of words' do
      activity_type_1 = create(:activity_type, name: 'petrol')
      create(:activity_type, name: 'petroleum')

      expect(ActivityTypeSearchService.search('petrol')).to eq([activity_type_1])
    end
  end

  context 'search by query term and key stages' do
    it 'filters by key stage' do
      key_stage_1 = create(:key_stage)
      key_stage_2 = create(:key_stage)
      activity_type_1 = create(:activity_type, name: 'foo one', key_stages: [key_stage_1])
      activity_type_2 = create(:activity_type, name: 'foo two', key_stages: [key_stage_2])

      expect(ActivityTypeSearchService.search('foo')).to match_array([activity_type_1, activity_type_2])
      expect(ActivityTypeSearchService.search('foo', [key_stage_1])).to eq([activity_type_1])
      expect(ActivityTypeSearchService.search('foo', [key_stage_2])).to eq([activity_type_2])
    end

    it 'does not return duplicates' do
      key_stage_1 = create(:key_stage)
      key_stage_2 = create(:key_stage)
      activity_type_1 = create(:activity_type, name: 'foo one', key_stages: [key_stage_1, key_stage_2])

      expect(ActivityTypeSearchService.search('foo', [key_stage_1, key_stage_2], [])).to eq([activity_type_1])
    end
  end

  context 'search by query term and subjects' do
    it 'filters by subject' do
      subject_1 = create(:subject)
      subject_2 = create(:subject)
      activity_type_1 = create(:activity_type, name: 'foo one', subjects: [subject_1])
      activity_type_2 = create(:activity_type, name: 'foo two', subjects: [subject_2])
      activity_types = ActivityType.where(id: [activity_type_1.id, activity_type_2.id])
      expect(ActivityTypeSearchService.search('foo').pluck(:id)).to match_array(activity_types.pluck(:id))
      expect(ActivityTypeSearchService.search('foo', [], [subject_1])).to eq([activity_type_1])
      expect(ActivityTypeSearchService.search('foo', [], [subject_2])).to eq([activity_type_2])
    end
  end
end

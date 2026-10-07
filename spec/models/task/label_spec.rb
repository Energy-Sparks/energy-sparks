# frozen_string_literal: true

require 'rails_helper'

describe Task::Label do
  subject(:label) { create(:label) }

  it { expect(label).to be_valid }

  context 'without a label type' do
    subject(:label) { build(:label, label_type: nil) }

    it { expect(label).not_to be_valid }
  end

  describe 'validations' do
    it { expect(label).to validate_presence_of(:name) }
    it { expect(label).to validate_uniqueness_of(:name).scoped_to(:label_type) }
  end

  describe 'label types' do
    it 'are the types tasks can be classified with' do
      expect(described_class.label_types.keys).to contain_exactly('aim', 'duration', 'topic', 'focus')
    end
  end

  describe 'relationships' do
    it 'can be assigned to an activity type as an aim' do
      expect(create(:activity_type, aims: [label]).aims).to contain_exactly(label)
    end

    it 'can be assigned to an activity type as a duration' do
      duration = create(:label, label_type: :duration)
      expect(create(:activity_type, durations: [duration]).durations).to contain_exactly(duration)
    end

    it 'can be assigned to an activity type as a topic' do
      topic = create(:label, label_type: :topic)
      expect(create(:activity_type, topics: [topic]).topics).to contain_exactly(topic)
    end

    it 'can be assigned to an intervention type as a focus' do
      focus = create(:label, label_type: :focus)
      expect(create(:intervention_type, focuses: [focus]).focuses).to contain_exactly(focus)
    end

    it { expect(label).to have_many(:label_items).dependent(:destroy) }
  end
end

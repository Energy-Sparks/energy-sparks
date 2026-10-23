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

  describe '.task_type' do
    it 'maps the activity label types to activity' do
      expect(described_class.task_type('aim')).to eq('activity')
    end

    it 'maps the action label types to action' do
      expect(described_class.task_type('focus')).to eq('action')
    end

    it 'returns nothing for an unknown label type' do
      expect(described_class.task_type('unknown')).to be_nil
    end

    it 'returns nothing when there is no label type' do
      expect(described_class.task_type(nil)).to be_nil
    end
  end

  describe 'relationships' do
    let(:activity_type) { create(:activity_type, aims: [aim], durations: [duration], topics: [topic]) }
    let(:aim) { create(:label, label_type: :aim) }
    let(:duration) { create(:label, label_type: :duration) }
    let(:topic) { create(:label, label_type: :topic) }

    it { expect(label).to have_many(:label_items).dependent(:destroy) }

    context 'when the label is an aim' do
      it { expect(activity_type.aims).to contain_exactly(aim) }
    end

    context 'when the label is a duration' do
      it { expect(activity_type.durations).to contain_exactly(duration) }
    end

    context 'when the label is a topic' do
      it { expect(activity_type.topics).to contain_exactly(topic) }
    end

    context 'when the label is a focus' do
      let(:focus_label) { create(:label, label_type: :focus) }
      let(:intervention_type) { create(:intervention_type, focuses: [focus_label]) }

      it { expect(intervention_type.focuses).to contain_exactly(focus_label) }
    end
  end

  describe 'usage' do
    context 'when the label is used by an activity' do
      let(:label) { create(:label, label_type: :aim) }

      before { create(:activity_type, aims: [label]) }

      it { expect(label.label_items.count).to eq(1) }
      it { expect(label.task_type).to eq('activity') }
    end

    context 'when the label is used by an action' do
      let(:label) { create(:label, label_type: :focus) }

      before { create(:intervention_type, focuses: [label]) }

      it { expect(label.label_items.count).to eq(1) }
      it { expect(label.task_type).to eq('action') }
    end
  end

  describe 'deletable' do
    let!(:label) { create(:label) }

    context 'when the label is not in use' do
      it { expect(label).to be_deletable }

      it 'deletes the label' do
        expect { label.destroy }.to change(described_class, :count).by(-1)
      end
    end

    context 'when the label is in use' do
      let!(:activity_type) { create(:activity_type, aims: [label]) }

      it { expect(label).not_to be_deletable }

      it 'does not delete the label' do
        expect { label.destroy }.not_to change(described_class, :count)
      end

      context 'when destroying the label' do
        before { label.destroy }

        it 'leaves the label items in place' do
          expect(activity_type.reload.aims).to contain_exactly(label)
        end

        it 'explains why the label cannot be deleted' do
          expect(label.errors.full_messages).to include('This label is in use and cannot be deleted')
        end
      end
    end
  end
end

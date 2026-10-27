# frozen_string_literal: true

require 'rails_helper'

describe Task::Label do
  subject(:label) { create(:label) }

  describe 'validations' do
    it { expect(label).to validate_presence_of(:name) }
    it { expect(label).to validate_uniqueness_of(:name).scoped_to(:label_type) }
    it { expect(label).to validate_presence_of(:label_type) }
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

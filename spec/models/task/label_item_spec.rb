# frozen_string_literal: true

require 'rails_helper'

describe Task::LabelItem do
  describe 'relationships' do
    subject(:label_item) { create(:label_item) }

    it { expect(label_item).to belong_to(:label) }
    it { expect(label_item).to belong_to(:task) }

    context 'when destroying the task' do
      before { label_item.task.destroy }

      it { expect { label_item.reload }.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe 'validations' do
    describe 'uniqueness of a label within a task' do
      subject(:duplicate) { build(:label_item, task:, label:) }

      let(:task) { create(:activity_type) }
      let(:label) { create(:label) }

      before do
        create(:label_item, task:, label:)
      end

      it 'prevents the same label being added to a task twice' do
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:label_id]).to be_present
      end
    end

    describe 'label type allowed for the task type' do
      subject(:label_item) { build(:label_item, task:, label:) }

      let(:task) { create(:intervention_type) }
      let(:label) { create(:label, label_type:) }
      let(:label_type) { :aim }

      context 'when the task type does not use the label type' do
        it 'prevents the label being added' do
          expect(label_item).not_to be_valid
          expect(label_item.errors[:label_type]).to be_present
        end
      end

      context 'when the task type uses the label type' do
        let(:label_type) { :focus }

        it 'allows the label being added' do
          expect(label_item).to be_valid
        end
      end
    end

    describe 'label types' do
      let(:activity_type) { create(:activity_type) }
      let(:intervention_type) { create(:intervention_type) }

      it 'are the types an activity type can be classified with' do
        expect(activity_type.label_types).to contain_exactly('aim', 'duration', 'topic')
      end

      it 'are the types an intervention type can be classified with' do
        expect(intervention_type.label_types).to contain_exactly('focus')
      end
    end
  end
end

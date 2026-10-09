# frozen_string_literal: true

require 'rails_helper'

describe Activities::ActivityTypeLearningStage do
  describe 'relationships' do
    subject(:activity_type_learning_stage) { create(:activity_type_learning_stage) }

    it { expect(activity_type_learning_stage).to belong_to(:activity_type) }
    it { expect(activity_type_learning_stage).to belong_to(:learning_stage) }

    context 'when destroying activity type' do
      before { activity_type_learning_stage.activity_type.destroy }

      it { expect { activity_type_learning_stage.reload }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe LearningStage do
  subject(:learning_stage) { create(:learning_stage) }

  it { is_expected.to be_valid }

  describe 'relationships' do
    it 'can be assigned to an activity type' do
      expect(create(:activity_type,
                    learning_stages: [learning_stage]).learning_stages).to contain_exactly(learning_stage)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe LearningStage do
  subject(:learning_stage) { create(:learning_stage) }

  it { expect(learning_stage).to be_valid }

  describe 'validations' do
    it { expect(learning_stage).to validate_presence_of(:country) }
    it { expect(learning_stage).to validate_presence_of(:name) }
    it { expect(learning_stage).to validate_uniqueness_of(:name).scoped_to(:country) }
    it { expect(learning_stage).to validate_presence_of(:abbreviation) }
    it { expect(learning_stage).to validate_uniqueness_of(:abbreviation).scoped_to(:country) }
  end

  describe 'relationships' do
    it 'can be assigned to an activity type' do
      expect(create(:activity_type,
                    learning_stages: [learning_stage]).learning_stages).to contain_exactly(learning_stage)
    end
  end
end

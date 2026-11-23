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
    it { expect(learning_stage).to have_many(:activity_type_learning_stages).dependent(:destroy) }
    it { expect(learning_stage).to have_many(:activity_types).through(:activity_type_learning_stages) }
  end

  describe '.abbreviations' do
    let!(:england_key_stage_one) { create(:learning_stage, abbreviation: 'KS1', country: :england) }
    let!(:england_key_stage_two) { create(:learning_stage, abbreviation: 'KS2', country: :england) }
    let!(:wales_progression_step) { create(:learning_stage, abbreviation: 'PS1', country: :wales) }

    it 'returns the abbreviations sorted by abbreviation' do
      stages = [wales_progression_step, england_key_stage_two, england_key_stage_one]
      expect(described_class.abbreviations(stages)).to eq(%w[KS1 KS2 PS1])
    end
  end

  it_behaves_like 'a deletable record',
                  'This learning stage is used by activity types and cannot be deleted',
                  using_association: :learning_stages do
    let(:record) { learning_stage }
    let(:record_in_use) { create(:activity_type, learning_stages: [record]) }
  end
end

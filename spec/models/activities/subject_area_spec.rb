# frozen_string_literal: true

require 'rails_helper'

describe Activities::SubjectArea do
  subject(:subject_area) { create(:subject_area) }

  it { expect(subject_area).to be_valid }

  describe 'validations' do
    it { expect(subject_area).to validate_presence_of(:name) }
    it { expect(subject_area).to validate_uniqueness_of(:name).scoped_to(:country) }
  end

  describe 'relationships' do
    it 'can be assigned to an activity type' do
      expect(create(:activity_type, subject_areas: [subject_area]).subject_areas).to contain_exactly(subject_area)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe Activities::Topic do
  subject(:topic) { create(:topic) }

  it { is_expected.to be_valid }

  describe 'relationships' do
    it 'can be assigned to an activity type' do
      expect(create(:activity_type, topics: [topic]).topics).to contain_exactly(topic)
    end
  end
end

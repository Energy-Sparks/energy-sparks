# frozen_string_literal: true

require 'rails_helper'

describe Activities::Duration do
  subject(:duration) { create(:duration) }

  it { is_expected.to be_valid }

  describe 'relationships' do
    it 'can be assigned to an activity type' do
      expect(create(:activity_type, durations: [duration]).durations).to contain_exactly(duration)
    end
  end
end

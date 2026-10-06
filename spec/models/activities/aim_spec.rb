# frozen_string_literal: true

require 'rails_helper'

describe Activities::Aim do
  subject(:aim) { create(:aim) }

  it { is_expected.to be_valid }

  describe 'relationships' do
    it 'can be assigned to an activity type' do
      expect(create(:activity_type, aims: [aim]).aims).to contain_exactly(aim)
    end
  end
end

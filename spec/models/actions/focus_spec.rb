# frozen_string_literal: true

require 'rails_helper'

describe Actions::Focus do
  subject(:focus_record) { create(:focus) }

  it { is_expected.to be_valid }

  describe 'relationships' do
    it 'can be assigned to an intervention type' do
      expect(create(:intervention_type, focuses: [focus_record]).focuses)
        .to contain_exactly(focus_record)
    end
  end
end

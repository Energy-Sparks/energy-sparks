# frozen_string_literal: true

require 'rails_helper'

describe Actions::InterventionTypeFocus do
  describe 'relationships' do
    subject(:intervention_type_focus) { create(:intervention_type_focus) }

    it { expect(intervention_type_focus).to belong_to(:intervention_type) }
    it { expect(intervention_type_focus).to belong_to(:focus) }

    context 'when destroying intervention type' do
      before { intervention_type_focus.intervention_type.destroy }

      it { expect { intervention_type_focus.reload }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end

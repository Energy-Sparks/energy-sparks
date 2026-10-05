# frozen_string_literal: true

require 'rails_helper'

describe Activities::InterventionTypeAim do
  describe 'relationships' do
    subject(:intervention_type_aim) { create(:intervention_type_aim) }

    it { expect(intervention_type_aim).to belong_to(:intervention_type) }
    it { expect(intervention_type_aim).to belong_to(:aim) }

    context 'when destroying intervention type' do
      before { intervention_type_aim.intervention_type.destroy }

      it { expect { intervention_type_aim.reload }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe Activities::ActivityTypeAim do
  describe 'relationships' do
    subject(:activity_type_aim) { create(:activity_type_aim) }

    it { expect(activity_type_aim).to belong_to(:activity_type) }
    it { expect(activity_type_aim).to belong_to(:aim) }

    context 'when destroying activity type' do
      before { activity_type_aim.activity_type.destroy }

      it { expect { activity_type_aim.reload }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe Activities::ActivityTypeDuration do
  describe 'relationships' do
    subject(:activity_type_duration) { create(:activity_type_duration) }

    it { expect(activity_type_duration).to belong_to(:activity_type) }
    it { expect(activity_type_duration).to belong_to(:duration) }

    context 'when destroying activity type' do
      before { activity_type_duration.activity_type.destroy }

      it { expect { activity_type_duration.reload }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe Activities::ActivityTypeSubjectArea do
  describe 'relationships' do
    subject(:activity_type_subject_area) { create(:activity_type_subject_area) }

    it { expect(activity_type_subject_area).to belong_to(:activity_type) }
    it { expect(activity_type_subject_area).to belong_to(:subject_area) }

    context 'when destroying activity type' do
      before { activity_type_subject_area.activity_type.destroy }

      it { expect { activity_type_subject_area.reload }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end

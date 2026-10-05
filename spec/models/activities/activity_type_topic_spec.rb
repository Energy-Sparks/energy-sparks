# frozen_string_literal: true

require 'rails_helper'

describe Activities::ActivityTypeTopic do
  describe 'relationships' do
    subject(:activity_type_topic) { create(:activity_type_topic) }

    it { expect(activity_type_topic).to belong_to(:activity_type) }
    it { expect(activity_type_topic).to belong_to(:topic) }

    context 'when destroying activity type' do
      before { activity_type_topic.activity_type.destroy }

      it { expect { activity_type_topic.reload }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end

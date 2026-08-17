# frozen_string_literal: true

require 'rails_helper'

describe Schools::Destroyer, :schools, type: :service do
  subject(:service) { described_class.new }

  shared_context 'with models to be deleted and ignored' do
    before do
      user = create(:school_admin, school: to_be_deleted, active: false)
      create(:contact_with_name_email_phone, school: to_be_deleted, user:)
      create(:school_admin, :with_cluster_schools, active: false, school: to_be_ignored, existing_school: to_be_deleted)

      meter = create(:electricity_meter_with_validated_reading, school: to_be_deleted, active: false)
      create(:amr_data_feed_reading, meter: meter)

      create(:issue, school: to_be_deleted)
      meter_issue = create(:issue, school: to_be_deleted)
      meter_issue.meters << meter
      meter_issue.save!
    end
  end

  shared_examples 'it destroys the expected schools' do
    it 'destroys the school' do
      expect { service.perform! }.to change(School, :count).by(-1) &
                                     change(User, :count).by(-1) &
                                     change(Meter, :count).by(-1) &
                                     change(AmrValidatedReading, :count).by(-1) &
                                     change(Contact, :count).by(-1) &
                                     change(Issue, :count).by(-2)
    end

    it 'ignores the other school' do
      service.perform!
      expect(to_be_ignored.users.count).to eq(1)
    end

    it 'removes association to unvalidated readings' do
      expect(AmrDataFeedReading.where(meter_id: nil).count).to eq(0)
      service.perform!
      expect(AmrDataFeedReading.where(meter_id: nil).count).to eq(1)
    end
  end

  describe '#perform!' do
    describe 'when there are archived schools' do
      # rubocop:disable RSpec/LetSetup
      include_context 'with models to be deleted and ignored' do
        let!(:to_be_deleted) { create(:school, :archived, archived_date: 3.years.ago) }
        let!(:to_be_ignored) { create(:school, :archived, archived_date: 3.years.ago + 1.day) }
      end
      # rubocop:enable RSpec/LetSetup

      it_behaves_like 'it destroys the expected schools'
    end

    describe 'when there are soft-deleted schools' do
      # rubocop:disable RSpec/LetSetup
      include_context 'with models to be deleted and ignored' do
        let!(:to_be_deleted) { create(:school, :deleted, removal_date: 3.years.ago) }
        let!(:to_be_ignored) { create(:school, :deleted, removal_date: 3.years.ago + 1.day) }
      end
      # rubocop:enable RSpec/LetSetup

      it_behaves_like 'it destroys the expected schools'
    end
  end
end

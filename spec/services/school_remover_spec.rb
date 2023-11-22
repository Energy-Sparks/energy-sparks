require 'rails_helper'

describe SchoolRemover, :schools, type: :service do
  let(:school)                   { create(:school, visible: false, number_of_pupils: 12) }
  let(:visible_school)           { create(:school, visible: true, number_of_pupils: 12) }

  let!(:school_admin)            { create(:school_admin, school: school) }
  let!(:contact)                 { create(:contact_with_name_email_phone, school: school, user: school_admin)}
  let!(:school_admin_user)       { create(:school_admin, school: school) }
  let!(:staff_user)              { create(:staff, school: school) }
  let!(:pupil_user)              { create(:pupil, school: school) }

  let!(:electricity_meter)       { create(:electricity_meter_with_validated_reading, school: school) }
  let!(:gas_meter)               { create(:gas_meter, :with_unvalidated_readings, school: school)}
  let!(:electricity_meter_issue) { create(:issue, school: school) }
  let!(:gas_meter_issue)         { create(:issue, school: school) }
  let!(:school_issue)            { create(:issue, school: school) }


  let(:archive) { false }
  let(:service) { SchoolRemover.new(school, archive: archive) }

  before do
    electricity_meter_issue.meters << electricity_meter
    electricity_meter_issue.save!
    gas_meter_issue.meters << gas_meter
    gas_meter_issue.save!
  end

  describe '#users_ready?' do
    context 'with all access locked all users' do
      before { school.users.each(&:lock_access!) }

      it 'returns true' do
        expect(visible_school.cluster_users.count).to eq(0)
        expect(school.users.count).to eq(4)
        expect(school.users.count(&:access_locked?)).to eq(4)
        expect(service.users_ready?).to eq(true)
      end
    end

    context 'with at least 1 access unlocked user' do
      before do
        school.users.each(&:lock_access!)
        school.users.first.unlock_access!
      end

      it 'returns false' do
        expect(visible_school.cluster_users.count).to eq(0)
        expect(school.users.count).to eq(4)
        expect(school.users.count(&:access_locked?)).to eq(3)
        expect(service.users_ready?).to eq(false)
      end
    end

    context 'with all access locked users except one which is associated with another school' do
      before do
        school.users.each(&:lock_access!)
        school.users.first.unlock_access!
        school.users.first.add_cluster_school(visible_school)
      end

      it 'returns true' do
        expect(visible_school.cluster_users.count).to eq(1)
        expect(school.users.count).to eq(4)
        expect(school.users.count(&:access_locked?)).to eq(3)
        expect(service.users_ready?).to eq(true)
      end
    end

    context 'with two access locked users and two unlocked users, only one of which is associated with another school' do
      before do
        school.users.each(&:lock_access!)
        school.users.first.unlock_access!
        school.users.second.unlock_access!
        school.users.first.add_cluster_school(visible_school)
      end

      it 'returns true' do
        expect(visible_school.cluster_users.count).to eq(1)
        expect(school.users.count).to eq(4)
        expect(school.users.count(&:access_locked?)).to eq(2)
        expect(service.users_ready?).to eq(false)
      end
    end
  end

  describe '#remove_school!' do
    it 'marks the school as inactive, sets removal date and deletes any school meter or school issues' do
      service.remove_school!
      expect(school.active).to be_falsey
      expect(school.process_data).to be_falsey
      expect(school.removal_date).to eq(Time.zone.today)
      expect(electricity_meter.issues.count).to eq 0
      expect(gas_meter.issues.count).to eq 0
      expect(school.issues.count).to eq 0
    end

    it 'fails if school is visible' do
      school.update(visible: true)
      expect do
        service.remove_school!
      end.to raise_error(SchoolRemover::Error)
    end

    context 'when archive flag set true' do
      let(:archive) { true }

      it 'marks the school as inactive but with no removal date or issue deletion' do
        service.remove_school!
        expect(school.active).to be_falsey
        expect(school.process_data).to be_falsey
        expect(school.removal_date).to be_nil
        expect(electricity_meter.issues.count).to eq 1
        expect(gas_meter.issues.count).to eq 1
        expect(school.issues.count).to eq 3
      end
    end
  end

  describe '#remove_users!' do
    let(:remove) { service.remove_users! }

    it 'locks the user accounts' do
      remove
      expect(school.users).to be_all(&:access_locked?)
    end

    it 'removes alert contacts' do
      remove
      expect(Contact.count).to eq 0
    end

    context 'when archiving' do
      let(:archive) { true }

      it 'keeps the alert contacts' do
        remove
        expect(school.users).to be_all(&:access_locked?)
        expect(Contact.count).to eq 1
      end
    end

    context 'when user is linked to other schools' do
      let(:other_school)  { create(:school) }

      before do
        school_admin.add_cluster_school(other_school)
        remove
      end

      it 'does not lock user and switches them to the other school' do
        school_admin.reload
        expect(school_admin).not_to be_access_locked
        expect(school_admin.school).to eq(other_school)
      end
    end

    context
  end

  describe '#remove_meters!' do
    before do
      service.remove_meters!
    end

    it 'deactivates the meters' do
      electricity_meter.reload
      expect(electricity_meter.active).to eq false
      gas_meter.reload
      expect(gas_meter.active).to eq false
    end

    it 'removes the validated data' do
      expect(AmrValidatedReading.count).to eq 0
    end

    it 'dissociates the unvalidated data' do
      expect(AmrDataFeedReading.first.meter).to be_nil
    end

    context 'when archive flag is set' do
      let(:archive) { true }

      it 'removes the validated data' do
        expect(AmrValidatedReading.count).to eq 0
      end

      it 'does not unlink the unvalidated data' do
        expect(AmrDataFeedReading.first.meter).not_to be_nil
      end
    end
  end

  # remove onboarding?
  # remove calendars?
end

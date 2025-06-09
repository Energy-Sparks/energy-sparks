# frozen_string_literal: true

require 'rails_helper'

describe User do
  include ActiveJob::TestHelper

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value('test@example.com').for(:email) }
    it { is_expected.not_to allow_value('\xE2\x80\x8Btest@example.com').for(:email) }
  end

  it 'generates display name' do
    user = create(:user, name: 'Name')
    expect(user.display_name).to eql user.name

    user = build(:user, name: nil).tap { |u| u.save!(validate: false) }
    expect(user.display_name).to eql user.email

    user = build(:user, name: '').tap { |u| u.save!(validate: false) }
    expect(user.display_name).to eql user.email
  end

  it 'returns school name' do
    user = create(:user)
    expect(user.school_name).to be_nil

    school = create(:school, name: 'Big School')
    user = create(:user, school:)
    expect(user.school_name).to eq('Big School')
  end

  describe 'when role is changed' do
    describe 'when group admin becomes school admin' do
      let!(:user) { create(:group_admin) }

      before do
        user.update!(role: :school_admin, school: create(:school), staff_role: create(:staff_role, :management))
      end

      it 'updates the role' do
        expect(user.school_group).to be_nil
      end
    end

    describe 'when school admin becomes group admin' do
      let!(:user) { create(:school_admin, :with_cluster_schools) }

      before do
        user.update!(role: :group_admin, school_group: create(:school_group))
      end

      it 'removes the schools' do
        expect(user.cluster_schools).to be_empty
      end
    end
  end

  describe '#default_school_group' do
    subject(:default_school_group) { user.default_school_group }

    context 'when user is a group admin with a school group (required)' do
      let(:user) { create(:group_admin) }

      it { expect(default_school_group).to eq(user.school_group) }
    end

    context 'when user is staff with a school' do
      let(:school) { create(:school, school_group:) }
      let(:user) { create(:staff, school:) }

      context 'when school has school group' do
        let(:school_group) { create(:school_group) }

        it { expect(default_school_group).to eq(school_group) }
      end

      context 'when school does not have school group' do
        let(:school) { create(:school) }

        it { expect(default_school_group).to be_nil }
      end
    end

    context 'when user has no school group or school' do
      let(:user) { create(:admin) }

      it { expect(default_school_group).to be_nil }
    end
  end

  describe '#default_school_group_name' do
    subject(:default_school_group_name) { user.default_school_group_name }

    context 'when user is a group admin with a school group (required)' do
      let(:user) { create(:group_admin) }

      it { expect(default_school_group_name).to eq(user.school_group.name) }
    end

    context 'when user is staff with a school' do
      let(:school) { create(:school, school_group:) }
      let(:user) { create(:staff, school:) }

      context 'when school has school group' do
        let(:school_group) { create(:school_group) }

        it { expect(default_school_group_name).to eq(school_group.name) }
      end

      context 'when school does not have school group' do
        let(:school) { create(:school) }

        it { expect(default_school_group_name).to be_nil }
      end
    end

    context 'when user has no school group or school' do
      let(:user) { create(:admin) }

      it { expect(default_school_group_name).to be_nil }
    end
  end

  describe 'pupil validation' do
    let(:school) { create(:school) }
    let!(:existing_pupil) { create(:pupil, pupil_password: 'three memorable words', school:) }

    it 'enforces minimum length' do
      expect(build(:pupil, school:, pupil_password: 'abc')).not_to be_valid
      expect(build(:pupil, school:, pupil_password: 'test')).not_to be_valid
      expect(build(:pupil, school:, pupil_password: 'testtesttest')).to be_valid
      expect(build(:pupil, school:, pupil_password: 'some memorable words')).to be_valid
    end

    it 'checks for unique passwords within the school' do
      expect(build(:pupil, school:, pupil_password: 'three memorable words')).not_to be_valid
      expect(build(:pupil, school:, pupil_password: 'three memorable words 123')).to be_valid
      expect(build(:pupil, school: create(:school), pupil_password: 'three memorable words')).to be_valid
    end

    it 'reads an pre-encrypted password' do
      ActiveRecord::Base.connection.exec_query(%q(
        UPDATE users
        SET pupil_password =
          '{"p":"ANilTF3GyyDTX6jwp6ZVgZkWr5CvalAAQg==","h":{"iv":"ctFZW5HRkVHmIbJd","at":"v775E47MO8eqOU8zo9xwPw=="}}'
        WHERE id = $1
      ), nil, [existing_pupil.id])
      expect(existing_pupil.reload.pupil_password).to eq('four memorable words here')
    end
  end

  describe 'staff roles as symbols' do
    it 'returns nil if no staff role' do
      expect(described_class.new.staff_role_as_symbol).to be_nil
    end

    it 'returns symbol if staff role' do
      staff_role_title = 'Awkward/Tricky and space'
      staff = build(:user, staff_role: build(:staff_role, title: staff_role_title))
      expect(staff.staff_role_as_symbol).to be :awkward_tricky_and_space
    end
  end

  describe '#schools' do
    context 'for user without school' do
      let(:user) { create(:user) }

      it 'returns empty' do
        expect(user.schools).to eq([])
      end
    end

    context 'for user with school' do
      let(:school)  { create(:school) }
      let(:user)    { create(:user, school:) }

      it 'returns schools' do
        expect(user.schools).to contain_exactly(school)
      end
    end

    context 'for group admin' do
      let(:school_group)    { create(:school_group) }
      let(:user)            { create(:user, role: :group_admin, school_group:) }

      context 'without schools in group' do
        it 'returns empty' do
          expect(user.schools).to eq([])
        end
      end

      context 'with schools in group' do
        let(:school_1)        { create(:school, school_group:) }
        let(:school_2)        { create(:school, school_group:) }
        let(:school_3)        { create(:school) }

        it 'returns schools from group' do
          expect(user.schools).to contain_exactly(school_1, school_2)
        end
      end
    end

    context 'for admin' do
      let(:school_1)        { create(:school) }
      let(:school_2)        { create(:school) }
      let(:user)            { create(:user, role: :admin) }

      it 'returns all schools' do
        expect(user.schools).to contain_exactly(school_1, school_2)
      end
    end
  end

  describe '.find_school_users_linked_to_other_schools' do
    let(:school)              { create(:school) }
    let(:school_2)            { create(:school) }
    let(:school_3)            { create(:school) }
    let!(:school_admin)       { create(:school_admin, school:) }
    let!(:staff_user)         { create(:staff, school:) }
    let!(:pupil_user)         { create(:pupil, school:) }

    context 'with users linked to other schools' do
      before do
        school_admin.add_cluster_school(school_2)
        staff_user.add_cluster_school(school_3)
      end

      it 'returns a collection of all school users supplied in a list of user ids linked with another school' do
        expect(school.users.count).to eq(3)
        expect(school_2.cluster_users.count).to eq(1)
        expect(school_3.cluster_users.count).to eq(1)
        expect(described_class.find_school_users_linked_to_other_schools(school_id: school,
                                                                         user_ids: school.users.pluck(:id))).to contain_exactly(
                                                                           school_admin, staff_user
                                                                         )
        expect(described_class.find_school_users_linked_to_other_schools(school_id: school,
                                                                         user_ids: [school_admin.id])).to contain_exactly(school_admin)
        expect(described_class.find_school_users_linked_to_other_schools(school_id: school,
                                                                         user_ids: [staff_user.id])).to contain_exactly(staff_user)
        expect(described_class.find_school_users_linked_to_other_schools(school_id: school,
                                                                         user_ids: [pupil_user.id])).to be_empty
      end
    end

    context 'with users not linked to other schools' do
      it 'returns an empty user collection' do
        expect(school.users.count).to eq(3)
        expect(school_2.cluster_users.count).to eq(0)
        expect(school_3.cluster_users.count).to eq(0)
        expect(described_class.find_school_users_linked_to_other_schools(school_id: school,
                                                                         user_ids: school.users.pluck(:id))).to be_empty
        expect(described_class.find_school_users_linked_to_other_schools(school_id: school,
                                                                         user_ids: [school_admin.id])).to be_empty
        expect(described_class.find_school_users_linked_to_other_schools(school_id: school,
                                                                         user_ids: [staff_user.id])).to be_empty
        expect(described_class.find_school_users_linked_to_other_schools(school_id: school,
                                                                         user_ids: [pupil_user.id])).to be_empty
      end
    end
  end

  describe 'welcome email' do
    let(:school) { create(:school) }
    let(:user) { create(:staff, school:, confirmed_at: nil) }

    it 'sends welcome email after confirmation for school roles' do
      expect(user.confirmed?).to be(false)
      expect(user.confirm).to be(true)

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq('Welcome to Energy Sparks')
    end

    it 'does not send welcome email for other users' do
      other_user = create(:user, role: :guest, confirmed_at: nil)
      expect(other_user.confirmed?).to be(false)
      expect(other_user.confirm).to be(true)

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq('Please confirm your account on Energy Sparks')
    end
  end

  describe '#admin_user_export_csv' do
    let!(:school_group) { create(:school_group) }
    let!(:school)       { create(:school, school_group:) }
    let!(:user)         { create(:staff, school:, confirmed_at: nil) }

    let(:csv)           { described_class.admin_user_export_csv }
    let(:parsed)        { CSV.parse(csv) }

    context 'when exporting' do
      it 'has the expected header' do
        expect(parsed[0]).to eq(['School Group',
                                 'School',
                                 'School type',
                                 'School active',
                                 'School data enabled',
                                 'Funder',
                                 'Region',
                                 'Name',
                                 'Email',
                                 'Role',
                                 'Staff Role',
                                 'Confirmed',
                                 'Locked'])
      end

      it 'includes the expected data' do
        expect(parsed[1]).to eq([school_group.name,
                                 school.name,
                                 school.school_type.humanize,
                                 'Yes',
                                 'Yes',
                                 '',
                                 '',
                                 user.name,
                                 user.email,
                                 user.role.humanize,
                                 user.staff_role.title,
                                 'No',
                                 'No'])
      end
    end

    context 'when exporting group admins' do
      let!(:user) { create(:group_admin, school_group:) }

      it 'includes the expected data' do
        expect(parsed[1]).to eq([school_group.name,
                                 '',
                                 '',
                                 '',
                                 '',
                                 '',
                                 '',
                                 user.name,
                                 user.email,
                                 'Group Admin',
                                 '',
                                 'Yes',
                                 'No'])
      end
    end

    context 'when there are pupil and admin users' do
      let!(:pupil)    { create(:pupil, school:) }
      let!(:admin)    { create(:admin) }

      it 'does not include those' do
        expect(parsed.length).to eq 2
      end
    end

    context 'when the school has a funder and region' do
      let!(:funder) { create(:funder) }
      let!(:school) { create(:school, school_group:, funder:, region: :east_of_england) }

      it 'includes those fields' do
        expect(parsed[1]).to eq([school_group.name,
                                 school.name,
                                 school.school_type.humanize,
                                 'Yes',
                                 'Yes',
                                 funder.name,
                                 'East Of England',
                                 user.name,
                                 user.email,
                                 user.role.humanize,
                                 user.staff_role.title,
                                 'No',
                                 'No'])
      end
    end
  end

  describe '#destroy' do
    shared_examples 'created by nullified on user destroy' do
      before { user.destroy! }

      it 'created_by is nullified' do
        expect(object.reload.created_by).to be_nil
      end
    end

    shared_examples 'updated by nullified on user destroy' do
      before { user.destroy! }

      it 'updated_by is nullified' do
        expect(object.reload.updated_by).to be_nil
      end
    end

    let!(:user) { create(:user) }

    context 'when observation has been created by user' do
      let!(:object) { create(:observation, :intervention, created_by: user) }

      it_behaves_like 'created by nullified on user destroy'
    end

    context 'when observation has been updated by user' do
      let!(:object) { create(:observation, :intervention, created_by: create(:user), updated_by: user) }

      it_behaves_like 'updated by nullified on user destroy'
    end

    context 'when energy tariff has been created by user' do
      let!(:object) { create(:energy_tariff, created_by: user) }

      it_behaves_like 'created by nullified on user destroy'
    end

    context 'when energy tariff has been updated by user' do
      let!(:object) { create(:energy_tariff, created_by: create(:user), updated_by: user) }

      it_behaves_like 'updated by nullified on user destroy'
    end

    context 'when issue has been created by user' do
      let!(:object) { create(:issue, created_by: user) }

      it_behaves_like 'created by nullified on user destroy'
    end

    context 'when issue has been updated by user' do
      let!(:object) { create(:issue, updated_by: user) }

      it_behaves_like 'updated by nullified on user destroy'
    end

    context 'when activity has been updated by user' do
      let!(:object) { create(:activity, updated_by: user) }

      it_behaves_like 'updated by nullified on user destroy'
    end

    context 'with linked school groups for issues admin' do
      let!(:school_group) { create(:school_group, default_issues_admin_user: user) }

      before { user.destroy! }

      it 'default_issues_admin is nullified' do
        expect(school_group.reload.default_issues_admin_user).to be_nil
      end
    end

    context 'when user has been created by another user' do
      let!(:object) { create(:user, created_by: user) }

      it_behaves_like 'created by nullified on user destroy'
    end

    context 'when removing from mailchmp' do
      context 'with user who isnt in the audience' do
        let!(:user) { create(:school_admin, school: create(:school)) }

        it 'does not submit a job' do
          expect(Mailchimp::UserDeletionJob).not_to receive(:perform_later)
          user.destroy!
        end
      end

      context 'with subscribed user' do
        let!(:user) { create(:school_admin, school: create(:school), mailchimp_status: :subscribed) }

        it 'submits a job' do
          expect(Mailchimp::UserDeletionJob).to receive(:perform_later).with(
            email_address: user.email,
            name: user.name,
            school: user.school.name
          )
          user.destroy!
        end

        context 'with cluster admin' do
          let!(:user) { create(:school_admin, :with_cluster_schools, mailchimp_status: :subscribed) }

          it 'submits a job to remove all tags' do
            expect(Mailchimp::UserDeletionJob).to receive(:perform_later).with(
              email_address: user.email,
              name: user.name,
              school: user.school.name
            )
            user.destroy!
          end
        end

        context 'with group admin' do
          let!(:user) { create(:group_admin, mailchimp_status: :subscribed) }

          it 'submits a job' do
            expect(Mailchimp::UserDeletionJob).to receive(:perform_later).with(
              email_address: user.email,
              name: user.name,
              school: user.school_group.name
            )
            user.destroy!
          end
        end
      end
    end
  end

  describe 'MailchimpUpdateable' do
    subject! { create(:user) }

    it_behaves_like 'a MailchimpUpdateable' do
      let(:mailchimp_field_changes) do
        {
          confirmed_at: Time.zone.now,
          name: 'New',
          preferred_locale: :cy,
          role: :admin,
          school: create(:school),
          school_group: create(:school_group),
          staff_role: create(:staff_role, :management),
          active: false
        }
      end

      let(:ignored_field_changes) do
        {
          sign_in_count: 5,
          unlock_token: 'XYZ'
        }
      end
    end
  end

  describe 'when changing associations used in Mailchimp' do
    subject!(:user) { create(:user) }

    context 'when changing cluster schools' do
      it 'updates timestamp when added' do
        user.add_cluster_school(create(:school))
        expect(user.mailchimp_fields_changed_at_previously_changed?).to be(true)
      end

      it 'updates timestamp when removed' do
        school = create(:school)
        user.add_cluster_school(school)
        user.remove_school(school)
        expect(user.mailchimp_fields_changed_at_previously_changed?).to be(true)
      end
    end

    context 'when changing contacts' do
      subject!(:user) { create(:school_admin) }

      it 'updates timestamp when contact added' do
        user.contacts.create!(email_address: user.email, name: user.name, school: user.school)
        expect(user.mailchimp_fields_changed_at_previously_changed?).to be(true)
      end

      it 'updates timestamp when contact removed' do
        user.contacts.create!(email_address: user.email, name: user.name, school: user.school)
        user.contacts.first.delete
        expect(user.mailchimp_fields_changed_at_previously_changed?).to be(true)
      end
    end
  end

  describe '.mailchimp_update_required' do
    context 'when mailchimp status is unknown' do
      let(:user) { create(:school_admin, school: create(:school, :with_school_group)) }

      it { expect(described_class.mailchimp_update_required).to be_empty }
    end

    context 'with school admin' do
      let!(:school) { create(:school, :with_school_group) }

      context 'when user has not been synchronised' do
        let!(:user) { create(:school_admin, school: school, mailchimp_status: :subscribed) }

        it { expect(described_class.mailchimp_update_required).to contain_exactly(user) }
      end

      context 'when user is up to date' do
        let!(:user) do
          user = create(:school_admin, school: school, mailchimp_status: :subscribed)
          user.update!(mailchimp_updated_at: Time.zone.now) # ensure timestamp is later
          user
        end

        it { expect(described_class.mailchimp_update_required).to be_empty }
      end

      context 'when updates are pending' do
        let!(:user) do
          user = create(:school_admin, school: school, mailchimp_status: :subscribed)
          user.update!(mailchimp_updated_at: 1.day.ago) # ensure timestamp is later
          user
        end

        context 'when user has been updated' do
          before do
            user.update!(name: 'New name')
          end

          it { expect(described_class.mailchimp_update_required).to contain_exactly(user) }
        end

        context 'when funder has been updated' do
          let!(:school) { create(:school, :with_school_group, funder: create(:funder)) }

          before do
            school.funder.update!(name: 'New funder name')
          end

          it { expect(described_class.mailchimp_update_required).to contain_exactly(user) }
        end

        context 'when local authority has been updated' do
          let!(:school) { create(:school, :with_school_group, local_authority_area: create(:local_authority_area)) }

          before do
            school.local_authority_area.update!(name: 'New area name')
          end

          it { expect(described_class.mailchimp_update_required).to contain_exactly(user) }
        end

        context 'when scoreboard has been updated' do
          let!(:school) { create(:school, :with_school_group, scoreboard: create(:scoreboard)) }

          before do
            school.scoreboard.update!(name: 'New scoreboard name')
          end

          it { expect(described_class.mailchimp_update_required).to contain_exactly(user) }
        end

        context 'when school_group has been updated' do
          let!(:school) { create(:school, :with_school_group) }

          before do
            school.school_group.update!(name: 'New group name')
          end

          it { expect(described_class.mailchimp_update_required).to contain_exactly(user) }
        end
      end
    end

    context 'with group admin' do
      let!(:user) { create(:group_admin) }

      context 'when user has not been synchronised' do
        let!(:user) { create(:group_admin, mailchimp_status: :subscribed) }

        it { expect(described_class.mailchimp_update_required).to contain_exactly(user) }
      end

      context 'when updates are pending' do
        let!(:user) do
          user = create(:group_admin, mailchimp_status: :subscribed)
          user.update!(mailchimp_updated_at: 1.day.ago) # ensure timestamp is later
          user
        end

        context 'when user has been updated' do
          before do
            user.update!(name: 'New name')
          end

          it { expect(described_class.mailchimp_update_required).to contain_exactly(user) }
        end

        context 'when school_group has been updated' do
          before do
            user.school_group.update!(name: 'New group name')
          end

          it { expect(described_class.mailchimp_update_required).to contain_exactly(user) }
        end
      end
    end
  end

  describe '#update_email_in_mailchimp' do
    let(:email) { 'old@example.org' }
    let(:user) { create(:user, email: email) }

    context 'when email not changed' do
      it 'does not update mailchimp' do
        expect(Mailchimp::EmailUpdaterJob).not_to receive(:perform_later)
        user.update!(name: 'New name')
      end
    end

    context 'when email changed' do
      around do |example|
        ClimateControl.modify ENVIRONMENT_IDENTIFIER: 'production' do
          example.run
        end
      end

      context 'when user is not in mailchimp' do
        it 'does not update mailchimp' do
          expect(Mailchimp::EmailUpdaterJob).not_to receive(:perform_later)
          user.update!(email: 'new@example.org')
        end
      end

      context 'when user is in mailchimp' do
        let(:user) { create(:user, email: email, mailchimp_status: :subscribed) }

        before do
          double = instance_double(Mailchimp::AudienceManager)
          allow(Mailchimp::AudienceManager).to receive(:new).and_return(double)
          member = ActiveSupport::OrderedOptions.new
          member.email = email
          member.status = 'subscribed'
          allow(double).to receive(:update_contact).and_return(member)
        end

        it 'updates mailchimp' do
          expect(Mailchimp::EmailUpdaterJob).to receive(:perform_later).with(user: user,
                                                                             original_email: email).and_call_original
          expect { user.update!(email: 'new@example.org') }.to have_enqueued_job
          perform_enqueued_jobs
          user.reload
          expect(user.mailchimp_updated_at).not_to be_nil
        end
      end
    end
  end
end

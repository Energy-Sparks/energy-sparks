require 'rails_helper'
require 'cancan/matchers'

describe User do
  it 'generates display name' do
    user = create(:user, name: 'Name')
    expect(user.display_name).to eql user.name

    user = create(:user, name: nil)
    expect(user.display_name).to eql user.email

    user = create(:user, name: '')
    expect(user.display_name).to eql user.email
  end

  it 'returns school name' do
    user = create(:user)
    expect(user.school_name).to be_nil

    school = create(:school, name: 'Big School')
    user = create(:user, school:)
    expect(user.school_name).to eq('Big School')
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
      expect(User.new.staff_role_as_symbol).to be_nil
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
        expect(User.find_school_users_linked_to_other_schools(school_id: school,
                                                              user_ids: school.users.pluck(:id))).to contain_exactly(
                                                                school_admin, staff_user
                                                              )
        expect(User.find_school_users_linked_to_other_schools(school_id: school,
                                                              user_ids: [school_admin.id])).to contain_exactly(school_admin)
        expect(User.find_school_users_linked_to_other_schools(school_id: school,
                                                              user_ids: [staff_user.id])).to contain_exactly(staff_user)
        expect(User.find_school_users_linked_to_other_schools(school_id: school,
                                                              user_ids: [pupil_user.id])).to be_empty
      end
    end

    context 'with users not linked to other schools' do
      it 'returns an empty user collection' do
        expect(school.users.count).to eq(3)
        expect(school_2.cluster_users.count).to eq(0)
        expect(school_3.cluster_users.count).to eq(0)
        expect(User.find_school_users_linked_to_other_schools(school_id: school,
                                                              user_ids: school.users.pluck(:id))).to be_empty
        expect(User.find_school_users_linked_to_other_schools(school_id: school,
                                                              user_ids: [school_admin.id])).to be_empty
        expect(User.find_school_users_linked_to_other_schools(school_id: school,
                                                              user_ids: [staff_user.id])).to be_empty
        expect(User.find_school_users_linked_to_other_schools(school_id: school,
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
      expect(email.subject).to eq('Energy Sparks: confirm your account')
    end
  end

  describe '#admin_user_export_csv' do
    let!(:school_group) { create(:school_group) }
    let!(:school)       { create(:school, school_group:) }
    let!(:user)         { create(:staff, school:, confirmed_at: nil) }

    let(:csv)           { User.admin_user_export_csv }
    let(:parsed)        { CSV.parse(csv) }

    context 'when exporting' do
      it 'has the expected header' do
        expect(parsed[0]).to eq(['School Group',
                                 'School',
                                 'School type',
                                 'Funder',
                                 'Region',
                                 'Name',
                                 'Email',
                                 'Role',
                                 'Staff Role',
                                 'Locked'])
      end

      it 'includes the expected data' do
        expect(parsed[1]).to eq([school_group.name,
                                 school.name,
                                 school.school_type.humanize,
                                 '',
                                 '',
                                 user.name,
                                 user.email,
                                 user.role.humanize,
                                 user.staff_role.title,
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
                                 user.name,
                                 user.email,
                                 'Group Admin',
                                 '',
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
                                 funder.name,
                                 'East Of England',
                                 user.name,
                                 user.email,
                                 user.role.humanize,
                                 user.staff_role.title,
                                 'No'])
      end
    end
  end
end

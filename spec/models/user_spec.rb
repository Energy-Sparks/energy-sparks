require 'rails_helper'
require "cancan/matchers"

describe User do

  it 'generates display name' do
    user = create(:user, name:"Name")
    expect(user.display_name).to eql user.name

    user = create(:user, name: nil)
    expect(user.display_name).to eql user.email

    user = create(:user, name: "")
    expect(user.display_name).to eql user.email
  end

  it 'returns school name' do
    user = create(:user)
    expect(user.school_name).to be_nil

    school = create(:school, name: 'Big School')
    user = create(:user, school: school)
    expect(user.school_name).to eq('Big School')
  end

  describe "#default_school_group" do
    let(:school) { }
    let(:school_group) { }
    let(:user) { create(:user, school_group: school_group, school: school) }
    subject(:default_school_group) { user.default_school_group }

    context "User has school with a school group" do
      let(:school) { create(:school, :with_school_group) }
      it { expect(default_school_group).to eq(school.school_group) }
    end
    context "User doesn't have school but has a school group" do
      let(:school_group) { create(:school_group) }
      it { expect(default_school_group).to eq(school_group) }
    end
    context "User has school with no school group but has group" do
      let(:school) { create(:school) }
      let(:school_group) { create(:school_group) }
      it { expect(default_school_group).to eq(school_group) }
    end
    context "User has school with no school group and no group" do
      let(:school) { create(:school) }
      it { expect(default_school_group).to be_nil }
    end
    context "User has no school or school group" do
      it { expect(default_school_group).to be_nil }
    end
  end

  it 'returns school group name' do
    user = create(:user)
    expect(user.school_group_name).to be_nil

    school_group = create(:school_group, name: 'Big Group')
    user = create(:user, school_group: school_group)
    expect(user.school_group_name).to eq('Big Group')

    school = create(:school, name: 'Big School', school_group: school_group)
    user = create(:user, school: school)
    expect(user.school_group_name).to eq('Big Group')
  end

  describe 'pupil validation' do
    let(:school){ create(:school) }
    let!(:existing_pupil){ create(:pupil, pupil_password: 'testtest', school: school) }

    it 'checks for unique passwords within the school' do
      expect(build(:pupil, school: school, pupil_password: 'testtest')).to_not be_valid
      expect(build(:pupil, school: school, pupil_password: 'testtest123')).to be_valid
      expect(build(:pupil, school: create(:school), pupil_password: 'testtest')).to be_valid
    end
  end

  describe 'staff roles as symbols' do

    it 'returns nil if no staff role' do
      expect(User.new().staff_role_as_symbol).to be nil
    end

    it 'returns symbol if staff role' do
      staff_role_title = 'Awkward/Tricky and space'
      staff = build(:user, staff_role: build(:staff_role, title: staff_role_title))
      expect(staff.staff_role_as_symbol).to be :awkward_tricky_and_space
    end
  end

  describe '#schools' do
    context 'for user without school' do
      let(:user)    { create(:user)}
      it 'returns empty' do
        expect(user.schools).to eq([])
      end
    end

    context 'for user with school' do
      let(:school)  { create(:school) }
      let(:user)    { create(:user, school: school)}
      it 'returns schools' do
        expect(user.schools).to match_array([school])
      end
    end

    context 'for group admin' do
      let(:school_group)    { create(:school_group) }
      let(:user)            { create(:user, role: :group_admin, school_group: school_group)}

      context 'without schools in group' do
        it 'returns empty' do
          expect(user.schools).to eq([])
        end
      end
      context 'with schools in group' do
        let(:school_1)        { create(:school, school_group: school_group) }
        let(:school_2)        { create(:school, school_group: school_group) }
        let(:school_3)        { create(:school) }
        it 'returns schools from group' do
          expect(user.schools).to match_array([school_1, school_2])
        end
      end
    end

    context 'for admin' do
      let(:school_1)        { create(:school) }
      let(:school_2)        { create(:school) }
      let(:user)            { create(:user, role: :admin)}

      it 'returns all schools' do
        expect(user.schools).to match_array([school_1, school_2])
      end
    end
  end

  describe 'welcome email' do
    let(:school) { create(:school) }
    let(:user) { create(:staff, school: school, confirmed_at: nil) }

    it 'sends welcome email after confirmation for school roles' do
      expect(user.confirmed?).to eql(false)
      expect(user.confirm ).to eql(true)

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq('Welcome to Energy Sparks')
    end

    it 'does not send welcome email for other users' do
      other_user = create(:user, role: :guest, confirmed_at: nil)
      expect(other_user.confirmed?).to eql(false)
      expect(other_user.confirm ).to eql(true)

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq('Energy Sparks: confirm your account')
    end

  end
end

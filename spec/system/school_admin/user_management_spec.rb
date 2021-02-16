require 'rails_helper'

describe 'School admin user management' do

  let(:school){ create(:school) }
  let(:school_admin){ create(:school_admin, school: school) }


  before(:each) do
    sign_in(school_admin)
    visit teachers_school_path(school)
  end

  describe 'for pupils' do

    it 'can create pupils' do

      click_on 'Manage users'
      click_on 'New pupil account'

      fill_in 'Name', with: 'The Pupils'
      fill_in 'Pupil password', with: 'the elektrons'
      click_on 'Create account'

      pupil = school.users.pupil.first
      expect(pupil.email).to_not be_nil
      expect(pupil.pupil_password).to eq('the elektrons')

      expect( ActionMailer::Base.deliveries.last ).to be_nil
    end

    it 'can edit and delete pupils' do
      pupil = create(:pupil, school: school)
      click_on 'Manage users'
      within '.pupils' do
        click_on 'Edit'
      end

      fill_in 'Name', with: 'Dave'
      click_on 'Update account'

      pupil.reload
      expect(pupil.name).to eq('Dave')

      within '.pupils' do
        click_on 'Delete'
      end

      expect(school.users.pupil.count).to eq(0)
    end

  end

  describe 'for staff' do
    let!(:teacher_role){ create :staff_role, :teacher, title: 'Teacher' }

    context 'it can create staff' do

      before(:each) do
        click_on 'Manage users'
        click_on 'New staff account'

        fill_in 'Name', with: 'Mrs Jones'
        fill_in 'Email', with: 'mrsjones@test.com'
        select 'Teacher', from: 'Role'
      end

      it 'can create staff with an alert contact' do
        expect { click_on 'Create account' }.to change { User.count }.by(1).and change { Contact.count }.by(1)

        staff = school.users.staff.first
        expect(staff.email).to eq('mrsjones@test.com')
        expect(staff.staff_role).to eq(teacher_role)
        expect(staff.confirmed?).to be false

        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq('Energy Sparks: confirm your account')
        expect(email.encoded).to match(school.name)
      end

      it 'can create staff without generating an alert contact' do
        uncheck 'Auto create alert contact'
        expect { click_on 'Create account' }.to change { User.count }.by(1).and change { Contact.count }.by(0)

        staff = school.users.staff.first
        expect(staff.email).to eq('mrsjones@test.com')
        expect(staff.staff_role).to eq(teacher_role)
        expect(staff.confirmed?).to be false

        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq('Energy Sparks: confirm your account')
        expect(email.encoded).to match(school.name)
      end

    end

    it 'can edit and delete staff' do
      staff = create(:staff, school: school)
      click_on 'Manage users'
      within '.staff' do
        click_on 'Edit'
      end

      fill_in 'Name', with: 'Ms Jones'
      click_on 'Update account'

      staff.reload
      expect(staff.name).to eq('Ms Jones')

      within '.staff' do
        click_on 'Delete'
      end
      expect(school.users.staff.count).to eq(0)
    end

  end

  describe 'for school admins' do

    let!(:management_role){ create(:staff_role, :management, title: 'Management') }

    it 'can create school admins' do

      click_on 'Manage users'
      click_on 'New school admin account'

      fill_in 'Name', with: 'Mrs Jones'
      fill_in 'Email', with: 'mrsjones@test.com'
      select 'Management', from: 'Role'
      click_on 'Create account'

      school_admin = school.users.school_admin.last
      expect(school_admin.email).to eq('mrsjones@test.com')
      expect(school_admin.confirmed?).to be false

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq('Energy Sparks: confirm your account')
      expect(email.encoded).to match(school.name)
    end

    context 'it can create school admins' do

      before(:each) do
        click_on 'Manage users'
        click_on 'New school admin account'

        fill_in 'Name', with: 'Mrs Jones'
        fill_in 'Email', with: 'mrsjones@test.com'
        select 'Management', from: 'Role'
      end

      it 'with an alert contact' do
        expect { click_on 'Create account' }.to change { User.count }.by(1).and change { Contact.count }.by(1)

        school_admin = school.users.school_admin.last
        expect(school_admin.email).to eq('mrsjones@test.com')
        expect(school_admin.confirmed?).to be false

        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq('Energy Sparks: confirm your account')
        expect(email.encoded).to match(school.name)
      end

      it 'without generating an alert contact' do
        uncheck 'Auto create alert contact'
        expect { click_on 'Create account' }.to change { User.count }.by(1).and change { Contact.count }.by(0)

        school_admin = school.users.school_admin.last
        expect(school_admin.email).to eq('mrsjones@test.com')
        expect(school_admin.confirmed?).to be false

        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq('Energy Sparks: confirm your account')
        expect(email.encoded).to match(school.name)
      end
    end

    it 'can edit school admins' do

      click_on 'Manage users'
      within '.school_admin' do
        click_on 'Edit'
      end

      fill_in 'Name', with: 'Ms Jones'
      click_on 'Update account'

      school_admin.reload
      expect(school_admin.name).to eq('Ms Jones')

    end

  end

end

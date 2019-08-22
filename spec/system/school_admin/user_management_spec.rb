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
    let!(:teacher_role){ create :staff_role, title: 'Teacher' }

    it 'can create teachers' do

      click_on 'Manage users'
      click_on 'New staff account'

      fill_in 'Name', with: 'Mrs Jones'
      fill_in 'Email', with: 'mrsjones@test.com'
      click_on 'Create account'

      staff = school.users.staff.first
      expect(staff.email).to eq('mrsjones@test.com')

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq('Energy Sparks: confirm your account')
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

  end




end

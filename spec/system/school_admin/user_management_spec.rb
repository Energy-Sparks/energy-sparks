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

  describe 'for school admins' do

  end


  describe 'for staff' do

  end


end

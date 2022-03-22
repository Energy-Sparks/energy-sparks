require 'rails_helper'

describe 'School admin school management' do

  let(:school){ create(:school) }
  let(:school_admin){ create(:school_admin, school: school) }

  describe 'as school admin' do
    before(:each) do
      sign_in(school_admin)
      visit management_school_path(school)
    end

    describe 'for tariffs' do
      it 'can see link to manage tariffs' do
        click_on 'Manage tariffs'
        expect(page).to have_content('Manage tariffs')
        expect(page).to have_link('electricity cost analysis')
        expect(page).to have_link('gas cost analysis')
      end
    end
  end
end

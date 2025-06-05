require 'rails_helper'

RSpec.describe 'School Partners', :schools, type: :system do
  let!(:school_group)  { create(:school_group, name: 'BANES') }
  let(:school_name)   { 'Oldfield Park Infants'}
  let!(:school)       { create_active_school(name: school_name, school_group: school_group) }
  let!(:admin)        { create(:admin)}


  context 'as admin' do
    context 'when managing partners', with_feature: :new_manage_school_pages do
      let!(:partner_1)         { create(:partner) }
      let!(:partner_2)         { create(:partner) }
      let!(:partner_3)         { create(:partner) }

      before do
        sign_in(admin)
        visit settings_school_path(school)
        click_on 'Manage partners'
      end

      it 'has a partner link on the school settings page' do
        expect(page).to have_content(school_name)
        expect(page).to have_content(partner_1.display_name)
      end

      it 'assigns partners to schools via text box position' do
        expect(page.find_field(partner_1.name).value).to be_blank
        expect(page.find_field(partner_2.name).value).to be_blank
        expect(page.find_field(partner_3.name).value).to be_blank

        fill_in partner_3.name, with: '1'
        fill_in partner_2.name, with: '2'

        click_on 'Update associated partners', match: :first

        click_on 'Manage partners'

        expect(school.partners).to match_array([partner_3, partner_2])
        expect(school.school_partners.first.position).to be 1
        expect(school.school_partners.last.position).to be 2

        fill_in partner_3.name, with: ''

        click_on 'Update associated partners', match: :first
        click_on 'Manage partners'

        school.reload
        expect(school.partners).to match_array([partner_2])
      end
    end
  end
end

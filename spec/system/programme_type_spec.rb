require 'rails_helper'

RSpec.describe "programme type", type: :system do

  let!(:school) { create(:school)}
  let!(:school_admin) { create(:school_admin, school: school)}

  let!(:programme_type_1) { create(:programme_type, title: 'prog1')}
  let!(:programme_type_2) { create(:programme_type, title: 'prog2', active: false)}
  let!(:programme_type_3) { create(:programme_type, title: 'prog3')}

  context 'as a public user' do
    before(:each) do
      visit programme_types_path
    end

    it 'shows active programme types' do
      expect(page).to have_content('prog1')
      expect(page).to have_content('prog3')

      expect(page).not_to have_content('prog2')
    end
  end

  context 'as a school admin' do
    before(:each) do
      sign_in school_admin
      visit programme_types_path
    end

    it 'prompts to start' do
      expect(school.programmes).to be_empty
      visit programme_type_path(programme_type_1)
      expect(page).to have_content('enrol your school')
      expect {
        click_link 'Start'
      }.to change(Programme, :count).by(1)
      expect(page).to have_content('You started this programme')
      expect(school.reload.programmes).not_to be_empty
    end
  end
end

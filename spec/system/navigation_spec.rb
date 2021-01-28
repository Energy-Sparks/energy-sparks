require 'rails_helper'

RSpec.describe "navigation links", type: :system do

  let(:school_group_name)       { 'Theresa Green Infants'}
  let(:school_name)             { 'Theresa Green Infants'}
  let!(:school_group)     { create(:school_group, name: school_group_name)}
  let!(:school)           { create(:school, name: school_name, school_group: school_group)}

  let!(:pupil)            { create(:pupil, school: school)}

  describe 'when logged in as pupil' do
    before(:each) do
      sign_in(pupil)
    end

    it 'click on Schools link goes to group page' do
      visit root_path(school)
      click_link 'Schools'
      expect(page).to have_content(school_group_name)
      expect(page).to have_content("Energy Sparks currently works with 1 schools from #{school_group_name}")
      expect(page).to have_link('View all schools')
    end

  end
end

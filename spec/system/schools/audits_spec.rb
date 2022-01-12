require 'rails_helper'

describe 'Audits', type: :system do

  let!(:school)            { create(:school) }

  describe 'as an admin' do
    let(:admin) { create(:admin) }

    before(:each) do
      sign_in(admin)
      visit school_path(school)
    end

    it 'displays an link to manage audits' do
      within '#manage_school_menu' do
        click_on 'Manage Audits'
      end
      expect(page).to have_content("Energy audits")
      expect(page).to have_content("New Audit")
    end

    it 'allows me to create, edit and delete an audit'
    it 'allows me to add, edit and delete an activity'
    it 'allows me to add, edit and delete an action'
  end

  describe 'as a school admin' do
    let!(:school_admin)       { create(:school_admin, school: school) }

    before(:each) do
      sign_in(school_admin)
      visit school_path(school)
    end

    it 'doesnt have link to manage audits' do
      expect(page).to_not have_content("Manage Audits")
    end

    it 'displays a link to view audits' do
      within '#my_school_menu' do
        click_on 'Energy audits'
      end
      expect(page).to have_content("Energy audits")
    end

    context 'with no audit' do
      before(:each) do
        visit school_audits_path(school)
      end
      it 'says there are none' do
        expect(page).to have_content("The Energy Sparks team have not carried out an energy audit for your school")
      end
      it 'offers an audit' do
        expect(page).to have_content("We are currently offering audits to a limited number of schools")
      end
    end

    context 'with an audit' do
      let!(:audit) { create(:audit, :with_activity_and_intervention_types, title: "Our audit", description: "Description of the audit", school: school) }

      it 'lets me view a list of audits' do
        visit school_audits_path(school)
        expect(page).to_not have_content("The Energy Sparks team have not carried out an energy audit for your school")
        expect(page).to have_content("Our audit")
      end

      it 'lets me view an audit' do
        visit school_audits_path(school)
        click_on("Our audit")
        expect(page).to have_content("Description of the audit")
      end

      it 'shows audit in timeline'
      it 'displays a link to view audit in timeline'
    end
  end

  describe 'as a staff member' do
    let!(:staff) { create(:staff, school: school) }

    before(:each) do
      sign_in(staff)
      visit school_path(school)
    end

    it 'displays a link to view audits' do
      within '#my_school_menu' do
        click_on 'Energy audits'
      end
      expect(page).to have_content("Energy audits")
    end

    it 'displays a link to view audit in timeline'
    it 'shows audit in timeline'
    it 'lets me view an audit'
  end

  describe 'as pupil' do
    let(:pupil)            { create(:pupil, school: school)}
    before(:each) do
      sign_in(pupil)
      visit school_path(school)
    end

    it 'displays a link to view audits' do
      within '#my_school_menu' do
        click_on 'Energy audits'
      end
      expect(page).to have_content("Energy audits")
    end

    it 'displays a link to view audit in timeline'
    it 'shows audit in timeline'
    it 'lets me view an audit'
  end

  describe 'as a guest user' do
    it 'does not display a link to view audit in timeline'
    it 'does not let me view an audit'
    it 'shows audit in timeline'

  end
end

require 'rails_helper'

describe 'viewing and recording action', type: :system do

  let(:title)       { "Changed boiler" }
  let(:summary)     { 'Old boiler bad, new boiler good' }
  let(:description) { 'How to change your boiler' }

  let!(:intervention_type){ create :intervention_type, title: title, summary: summary, description: description }

  let!(:school) { create_active_school() }

  context 'as a public user' do

    it 'there is a top-level navigation item' do
      visit root_path
      expect(page).to have_link("Actions", href: intervention_type_groups_path)
    end

    context 'viewing an action' do
      before(:each) do
        visit intervention_type_path(intervention_type)
      end

      it 'should display title' do
        expect(page).to have_content(title)
      end

      it 'should display score' do
        expect(page).to have_content("#{intervention_type.points} points for this action")
      end

      it 'should display description' do
        expect(page).to have_content(intervention_type.description.to_plain_text)
        expect(page).to have_content(intervention_type.summary)
      end

      it 'should display navigation' do
        expect(page).to have_link("View #{intervention_type.intervention_type_group.intervention_types.count} related actions")
      end

      it 'should display resource links' do
        expect(page).to have_content(intervention_type.download_links.to_plain_text)
      end

      it 'should display prompt to login' do
        expect(page).to have_content("Are you an Energy Sparks user?")
        expect(page).to have_link("Sign in to record action")
      end
    end

    context 'when logging in to record' do
      let!(:staff)  { create(:staff, school: school)}

      before(:each) do
        visit intervention_type_path(intervention_type)
      end

      it 'should redirect back to activity after login' do
        click_on "Sign in to record action"
        fill_in 'Email', with: staff.email
        fill_in 'Password', with: staff.password
        within '#staff' do
          click_on 'Sign in'
        end
        expect(page).to have_content(intervention_type.title)
        expect(page).to have_content("Complete this action to score your school #{intervention_type.points} points!")
      end
    end
  end

  context 'as a school admin' do
    let!(:school_admin)       { create(:school_admin, school: school)}

    before(:each) do
      sign_in(school_admin)
      visit intervention_type_path(intervention_type)
    end

    context 'viewing an action' do
      it 'should not see prompt to login' do
        expect(page).to_not have_link("Sign in to record action")
      end

      it 'should see prompt to record it' do
        expect(page).to have_content("Complete this action to score your school #{intervention_type.points} points!")
        expect(page).to have_link("Record this action")
      end
    end

    context 'viewing a previously recorded action' do
      let!(:observation) { create(:observation, :intervention, intervention_type: intervention_type, school: school)}

      before(:each) do
        refresh
      end
      it 'should see previous records' do
        expect(page).to have_content("Action previously completed")
        expect(page).to have_content("once")
      end

      it 'should link to the activity' do
        expect(page).to have_link(href: school_intervention_path(school, observation))
      end
    end

    context 'recording an action' do
      it 'allows an action to be created' do
        click_on 'Record this action'

        fill_in_trix with: 'We changed to a more efficient boiler'
        fill_in 'observation_at', with: ''
        click_on 'Record action'

        expect(page).to have_content("can't be blank")

        fill_in 'observation_at', with: '01/07/2019'
        click_on 'Record action'

        observation = school.observations.intervention.first
        expect(observation.intervention_type).to eq(intervention_type)
        expect(observation.at.to_date).to eq(Date.new(2019, 7, 1))
      end
    end

    context 'editing an action' do
      let!(:observation) { create(:observation, :intervention, intervention_type: intervention_type, school: school)}

      it 'can be updated' do
        visit management_school_path(school)
        click_on 'View all events'

        within '.application' do
          click_on 'Edit'
        end

        fill_in_trix with: 'We changed to a more efficient boiler'
        fill_in 'observation_at', with: '20/06/2019', visible: false
        click_on 'Update action'

        observation.reload
        expect(observation.at.to_date).to eq(Date.new(2019, 6, 20))

        click_on 'Changed boiler'
        expect(page).to have_content('We changed to a more efficient boiler')

      end

      it 'can be deleted' do
        visit management_school_path(school)
        click_on 'View all events'

        expect{
          click_on 'Delete'
        }.to change{Observation.count}.from(1).to(0)
      end
    end
  end
end

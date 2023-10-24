require 'rails_helper'

describe 'viewing and recording action', type: :system do
  let(:title)       { "Changed boiler" }
  let(:summary)     { 'Old boiler bad, new boiler good' }
  let(:description) { 'How to change your boiler' }
  let(:photo_bonus_points) { nil }
  let!(:intervention_type) { create :intervention_type, name: title, summary: summary, description: description }
  let(:school) { create_active_school }

  before do
    SiteSettings.current.update(photo_bonus_points: photo_bonus_points)
  end

  context 'as a public user' do
    it 'there is a top-level navigation item' do
      visit root_path
      expect(page).to have_link("Actions", href: intervention_type_groups_path)
    end

    context 'viewing an action' do
      before do
        visit intervention_type_path(intervention_type)
      end

      it 'displays title' do
        expect(page).to have_content(title)
      end

      it 'displays score' do
        expect(page).to have_content("#{intervention_type.score} points for this action")
      end

      it 'displays description' do
        expect(page).to have_content(intervention_type.description.to_plain_text)
        expect(page).to have_content(intervention_type.summary)
      end

      it 'displays navigation' do
        expect(page).to have_link("View #{intervention_type.intervention_type_group.intervention_types.count} related action")
      end

      it 'displays resource links' do
        expect(page).to have_content(intervention_type.download_links.to_plain_text)
      end

      it 'displays prompt to login' do
        expect(page).to have_content("Are you an Energy Sparks user?")
        expect(page).to have_link("Sign in to record action")
      end
    end

    context 'when logging in to record' do
      let!(:staff) { create(:staff, school: school)}

      before do
        visit intervention_type_path(intervention_type)
      end

      it 'redirects back to intervention after login' do
        click_on "Sign in to record action"
        fill_in 'Email', with: staff.email
        fill_in 'Password', with: staff.password
        within '#staff' do
          click_on 'Sign in'
        end
        expect(page).to have_content(intervention_type.name)
        expect(page).to have_content("Complete this action to score your school #{intervention_type.score} points!")
      end
    end
  end

  context 'as a group admin' do
    let!(:group_admin)    { create(:group_admin)}
    let!(:other_school)   { create(:school, name: 'Other School', school_group: group_admin.school_group)}

    before do
      school.update(school_group: group_admin.school_group)
      sign_in(group_admin)
      visit intervention_type_path(intervention_type)
    end

    context 'viewing an intervention type' do
      it 'sees prompt to record it' do
        expect(page).to have_content("Complete this action on behalf of a school to score #{intervention_type.score} points!")
        expect(page).to have_button("Record this action")
      end

      it 'redirects to new intervention recording page' do
        select other_school.name, from: :school_id
        click_on "Record this action"
        expect(page).to have_content("Record an energy saving action for your school")
        expect(page).to have_content(other_school.name)
      end
    end

    context 'recording an intervention' do
      it 'associates intervention with correct school from group' do
        select other_school.name, from: :school_id
        click_on "Record this action"
        fill_in :observation_at, with: Time.zone.today.strftime("%d/%m/%Y")
        click_on 'Record action'
        expect(page).to have_content("Congratulations! We've recorded your action")
        expect(other_school.observations.count).to eq(1)
      end
    end

    context 'when school is not in group' do
      let(:school_not_in_group) { create(:school)}

      it 'does not allow recording an intervention' do
        visit new_school_intervention_path(school_not_in_group, intervention_type_id: intervention_type.id)
        expect(page).to have_content("You are not authorized to access this page")
        expect(page).not_to have_button("Record action")
      end
    end
  end

  context 'as an admin' do
    let(:admin)       { create(:admin)}
    let!(:school_1)   { create(:school)}
    let!(:school_2)   { create(:school)}

    before do
      sign_in(admin)
      visit intervention_type_path(intervention_type)
    end

    context 'viewing an intervention type' do
      it 'sees prompt to record it' do
        expect(page).to have_content("Complete this action on behalf of a school to score #{intervention_type.score} points!")
        expect(page).to have_button("Record this action")
      end

      it 'redirects to new activity recording page' do
        select school_1.name, from: :school_id
        click_on "Record this action"
        expect(page).to have_content("Record an energy saving action for your school")
        expect(page).to have_content(school_1.name)
      end
    end
  end

  context 'as a school admin' do
    let!(:school_admin)       { create(:school_admin, school: school)}

    before do
      sign_in(school_admin)
      visit intervention_type_path(intervention_type)
    end

    context 'viewing an action' do
      it 'does not see prompt to login' do
        expect(page).not_to have_link("Sign in to record action")
      end

      it 'sees prompt to record it' do
        expect(page).to have_content("Complete this action to score your school #{intervention_type.score} points!")
        expect(page).to have_link("Record this action")
      end
    end

    context 'viewing a previously recorded action' do
      let!(:observation) { create(:observation, :intervention, intervention_type: intervention_type, school: school)}

      before do
        refresh
      end

      it 'sees previous records' do
        expect(page).to have_content("Action previously completed")
        expect(page).to have_content("once")
      end

      it 'links to the intervention' do
        expect(page).to have_link(href: school_intervention_path(school, observation))
      end
    end

    context 'recording an action' do
      it 'allows an action to be created' do
        click_on 'Record this action'

        fill_in 'observation_at', with: ''
        click_on 'Record action'

        expect(page).to have_content("can't be blank")

        fill_in 'observation_at', with: Time.zone.today.strftime("%d/%m/%Y")
        fill_in_trix with: 'We changed to a more efficient boiler'
        fill_in 'How many pupils were involved in this activity?', with: 3

        click_on 'Record action'

        expect(page).to have_content("Congratulations! We've recorded your action")
        expect(page).to have_content("You've just scored #{intervention_type.score} points")

        click_on 'View your action'

        expect(page).to have_content('We changed to a more efficient boiler')

        observation = school.observations.intervention.first
        expect(observation.intervention_type).to eq(intervention_type)
        expect(observation.points).to eq(intervention_type.score)
        expect(observation.at.to_date).to eq(Time.zone.today)
      end

      it 'does not show points if none scored' do
        click_on 'Record this action'
        fill_in 'observation_at', with: 2.years.ago # points are not scored for actions in previous aademic year
        fill_in_trix with: 'We changed to a more efficient boiler'
        click_on 'Record action'
        expect(page).to have_content("Congratulations! We've recorded your action")

        expect(page).not_to have_content("You've just scored #{intervention_type.score} points")
        observation = school.observations.intervention.first
        expect(observation.points).to be_nil
      end

      context "showing photobonus points message" do
        let(:photo_bonus_points) { nil }

        before do
          click_on 'Record this action'
        end

        context "site settings photo_bonus_points is nil" do
          it { expect(page).not_to have_content("Adding a photo to document your action will score you")}
        end

        context "site settings photo_bonus_points is set" do
          let(:photo_bonus_points) { 5 }

          it { expect(page).to have_content("Adding a photo to document your action will score you 5 bonus points")}
        end

        context "site settings photo_bonus_points is 0" do
          let(:photo_bonus_points) { 0 }

          it { expect(page).not_to have_content("Adding a photo to document your action will score you")}
        end
      end

      context "photo is provided" do
        let(:photo_bonus_points) { 5 }

        it "adds photo bonus" do
          click_on 'Record this action'
          fill_in 'observation_at', with: Time.zone.today
          fill_in_trix with: 'We changed to a more efficient boiler<figure></figure>'
          click_on 'Record action'
          expect(page).to have_content("You've just scored #{intervention_type.score + photo_bonus_points} points")
        end
      end

      context 'on podium' do
        context 'nil points' do
          let!(:scoreboard) { create :scoreboard }

          before do
            school.update!(scoreboard: scoreboard)
          end

          it 'records action' do
            click_on 'Record this action'
            fill_in 'observation_at', with: Time.zone.today.strftime("%d/%m/%Y")
            fill_in 'How many pupils were involved in this activity?', with: 3
            fill_in_trix with: 'We changed to a more efficient boiler'
            click_on 'Record action'
            expect(page).to have_content("Congratulations! We've recorded your action")
          end
        end

        context 'with points' do
          let!(:scoreboard)   { create :scoreboard }
          let(:points)        { 10 }
          let(:school)        { create :school, :with_points, score_points: points, scoreboard: scoreboard }

          context 'in first place' do
            it 'records action' do
              click_on 'Record this action'
              fill_in 'observation_at', with: Time.zone.today.strftime("%d/%m/%Y")
              fill_in_trix with: 'We changed to a more efficient boiler'
              fill_in 'How many pupils were involved in this activity?', with: 3
              click_on 'Record action'
              expect(page).to have_content("Congratulations! We've recorded your action")
              expect(page).to have_content("You've just scored #{intervention_type.score} points")
              #2 actions, because one created via :with_points above
              expect(page).to have_content("You've recorded 2 actions so far this year")
              expect(page).to have_content("and your school is currently in 1st place")
            end
          end

          context 'in second place' do
            let!(:school_2) { create :school, :with_points, score_points: 1000, scoreboard: scoreboard }

            it 'records action' do
              click_on 'Record this action'
              fill_in 'observation_at', with: Time.zone.today.strftime("%d/%m/%Y")
              fill_in 'How many pupils were involved in this activity?', with: 3
              fill_in_trix with: 'We changed to a more efficient boiler'
              click_on 'Record action'
              expect(page).to have_content("Congratulations! We've recorded your action")
              expect(page).to have_content("You've just scored #{intervention_type.score} points")
              #2 actions, because one created via :with_points above
              expect(page).to have_content("You've recorded 2 actions so far this year")
              expect(page).not_to have_content("and your school is currently in 1st place")
              expect(page).to have_content("to reach 1st place")
            end
          end
        end
      end
    end

    context 'editing an action' do
      let!(:observation) { create(:observation, :intervention, intervention_type: intervention_type, school: school)}

      it 'can be updated' do
        visit school_path(school)
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
        visit school_path(school)
        click_on 'View all events'

        expect do
          click_on 'Delete'
        end.to change {Observation.count}.from(1).to(0)
      end
    end
  end
end

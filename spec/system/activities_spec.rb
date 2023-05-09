require 'rails_helper'

describe 'viewing and recording activities', type: :system do

  let!(:activity_category) { create(:activity_category)}

  let!(:subject)  { Subject.create(name: "Science and Technology") }
  let!(:ks1)      { KeyStage.create(name: 'KS1') }
  let(:activity_data_driven)    { true }
  let(:school_data_enabled)     { true }

  let(:activity_type_name)           { 'Exciting activity' }
  let(:activity_description)    { "It's An #{activity_type_name}" }

  let!(:activity_type) { create(:activity_type, name: activity_type_name, activity_category: activity_category, description: activity_description, key_stages: [ks1], subjects: [subject], data_driven: activity_data_driven) }

  let(:school) { create_active_school(data_enabled: school_data_enabled) }

  context 'as a public user' do

    before(:each) do
      visit activity_type_path(activity_type)
    end

    context 'viewing an activity type' do
      it 'should display title' do
        expect(page).to have_content(activity_type_name)
      end

      it 'should display tags' do
        expect(page).to have_content(ks1.name)
        expect(page).to have_content(subject.name)
      end

      it 'should display score' do
        expect(page).to have_content(activity_type.score)
      end

      it 'should display description' do
        expect(page).to have_content(activity_type.description.to_plain_text)
        expect(page).to_not have_content(activity_type.school_specific_description.to_plain_text)
      end

      it 'should display navigation' do
        expect(page).to have_link("View #{activity_category.activity_types.count} related activity")
      end

      it 'should display resource links' do
        expect(page).to have_content(activity_type.download_links.to_plain_text)
      end

      it 'should display prompt to login' do
        expect(page).to have_content("Are you an Energy Sparks user?")
        expect(page).to have_link("Sign in to record activity")
      end

    end

    context 'when logging in to record' do
      let!(:staff)  { create(:staff, school: school)}

      it 'should redirect back to activity after login' do
        click_on "Sign in to record activity"
        fill_in 'Email', with: staff.email
        fill_in 'Password', with: staff.password
        within '#staff' do
          click_on 'Sign in'
        end
        expect(page).to have_content(activity_type.name)
        expect(page).to have_content("Complete this activity to score your school #{activity_type.score} points!")
      end
    end
  end

  context 'as a teacher' do
    let!(:staff)  { create(:staff, school: school)}

    before(:each) do
      sign_in(staff)
      visit activity_type_path(activity_type)
    end

    context 'viewing an activity type' do
      it 'should see school specific content' do
        expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
        expect(page).to_not have_content(activity_type.description.to_plain_text)
      end

      it 'should not see prompt to login' do
        expect(page).to_not have_link("Sign in to record activity")
      end

      it 'should see prompt to record it' do
        expect(page).to have_content("Complete this activity to score your school #{activity_type.score} points!")
        expect(page).to have_link("Record this activity")
      end
    end

    context 'viewing a previously recorded activity' do
      let!(:activity)     { create(:activity, school: school, activity_type: activity_type) }

      before(:each) do
        refresh
      end

      context 'when school is data enabled' do
        it 'should see previous records' do
          expect(page).to have_content("Activity previously completed")
          expect(page).to have_content("once")
        end

        it 'should link to the activity' do
          expect(page).to have_link(href: school_activity_path(school, activity))
        end

        it 'should show school specific description' do
          visit school_activity_path(school, activity)
          expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to_not have_content(activity_type.description.to_plain_text)
        end
      end

      context 'when school not data enabled' do
        let(:school_data_enabled) { false }

        it 'should show generic description' do
          visit school_activity_path(school, activity)
          expect(page).to_not have_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to have_content(activity_type.description.to_plain_text)
        end

        context 'when activity not data driven' do
          let(:activity_data_driven)  { false }

          it 'should show school specific description' do
            visit school_activity_path(school, activity)
            expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
            expect(page).to_not have_content(activity_type.description.to_plain_text)
          end
        end
      end

    end

    context 'recording an activity' do
      let(:activity_description) { 'What we did' }

      it 'allows an activity to be created' do
        visit activity_type_path(activity_type)

        click_on 'Record this activity'
        fill_in :activity_happened_on, with: Date.today.strftime("%d/%m/%Y")

        click_on 'Save activity'
        expect(page.has_content?("Congratulations! We've recorded your activity")).to be true
        expect(page.has_content?("You've just scored #{activity_type.score} points")).to be true
        click_on 'View your activity'
        expect(page.has_content?(activity_type_name)).to be true
        expect(page.has_content?(Date.today.strftime("%A, %d %B %Y"))).to be true
      end

      context 'which is custom' do
        let(:custom_title) { 'Custom title' }

        let(:other_activity_type_name) { 'Exciting activity (please specify)' }
        let!(:other_activity_type) { create(:activity_type, name: other_activity_type_name, description: nil, custom: true) }

        before(:each) do
          visit activity_type_path(other_activity_type)
        end

        it 'allows a title to be added' do
          click_on 'Record this activity'
          fill_in :activity_title, with: custom_title
          fill_in_trix with: activity_description
          fill_in :activity_happened_on, with: Date.today.strftime("%d/%m/%Y")

          click_on 'Save activity'
          expect(page.has_content?("Congratulations! We've recorded your activity")).to be true

          click_on 'View your activity'
          expect(page.has_content?(activity_description)).to be true
          expect(page.has_content?(custom_title)).to be true
        end
      end

      context 'on podium' do
        context 'nil points' do
          let!(:scoreboard)   { create :scoreboard }
          before(:each) do
            school.update!(scoreboard: scoreboard)
          end
          it 'records activity' do
             visit activity_type_path(activity_type)
             click_on 'Record this activity'
             fill_in :activity_happened_on, with: Date.today.strftime("%d/%m/%Y")
             click_on 'Save activity'
             expect(page.has_content?("Congratulations! We've recorded your activity")).to be true
          end
        end
        context 'with points' do
          let!(:scoreboard)   { create :scoreboard }
          let(:points)        { 10 }
          let(:school)        { create :school, :with_points, score_points: points, scoreboard: scoreboard }

          context 'in first place' do
            it 'records activity' do
              visit activity_type_path(activity_type)
              click_on 'Record this activity'
              fill_in :activity_happened_on, with: Date.today.strftime("%d/%m/%Y")
              click_on 'Save activity'
              expect(page.has_content?("Congratulations! We've recorded your activity")).to be true
              expect(page.has_content?("You've just scored #{activity_type.score} points")).to be true
              expect(page.has_content?("and your school is currently in 1st place")).to be true
            end
          end
          context 'in second place' do
            let!(:school_2) { create :school, :with_points, score_points: 1000, scoreboard: scoreboard }

            it 'records activity' do
              visit activity_type_path(activity_type)
              click_on 'Record this activity'
              fill_in :activity_happened_on, with: Date.today.strftime("%d/%m/%Y")
              click_on 'Save activity'
              expect(page.has_content?("Congratulations! We've recorded your activity")).to be true
              expect(page.has_content?("You've just scored #{activity_type.score} points")).to be true
              expect(page.has_content?("and your school is currently in 1st place")).to_not be true
              expect(page.has_content?("to reach 1st place")).to be true
            end
          end
        end
      end
    end
  end

  context 'as a group admin' do
    let!(:group_admin)    { create(:group_admin)}
    let!(:other_school)   { create(:school, name: 'Other School', school_group: group_admin.school_group)}

    before(:each) do
      school.update(school_group: group_admin.school_group)
      sign_in(group_admin)
      visit activity_type_path(activity_type)
    end

    context 'viewing an activity type' do
      it 'should see prompt to record it' do
        expect(page).to have_content("Complete this activity on behalf of a school to score #{activity_type.score} points!")
        expect(page).to have_button("Record this activity")
      end

      it 'should use the Activity Type Filter to check for appropriate schools' do
        expect(ActivityTypeFilter).to receive(:new).with(school: school).and_call_original
        expect(ActivityTypeFilter).to receive(:new).with(school: other_school).and_call_original
        visit activity_type_path(activity_type)
      end

      it 'should redirect to new activity recording page' do
        select other_school.name, from: :school_id
        click_on "Record this activity"
        expect(page).to have_content("Record a new energy saving activity for your school")
        expect(page).to have_content(other_school.name)
      end
    end

    context 'recording an activity' do
      it 'should associate activity with correct school from group' do
        select other_school.name, from: :school_id
        click_on "Record this activity"
        fill_in :activity_happened_on, with: Date.today.strftime("%d/%m/%Y")
        click_on 'Save activity'
        expect(page).to have_content("Congratulations! We've recorded your activity")
        expect(other_school.activities.count).to eq(1)
      end
    end

    context 'when school is not in group' do
      let(:school_not_in_group)   { create(:school)}

      it 'should not allow recording an activity' do
        visit new_school_activity_path(school_not_in_group, activity_type_id: activity_type.id)
        expect(page).to have_content("You are not authorized to access this page")
        expect(page).not_to have_button("Save activity")
      end
    end
  end

  context 'as an admin' do
    let(:admin)       { create(:admin)}
    let!(:school_1)   { create(:school)}
    let!(:school_2)   { create(:school)}

    before(:each) do
      sign_in(admin)
      visit activity_type_path(activity_type)
    end

    context 'viewing an activity type' do
      it 'should see prompt to record it' do
        expect(page).to have_content("Complete this activity on behalf of a school to score #{activity_type.score} points!")
        expect(page).to have_button("Record this activity")
      end

      it 'should not use the Activity Type Filter to check for appropriate schools' do
        expect(ActivityTypeFilter).not_to receive(:new)
        visit activity_type_path(activity_type)
      end

      it 'should redirect to new activity recording page' do
        select school_1.name, from: :school_id
        click_on "Record this activity"
        expect(page).to have_content("Record a new energy saving activity for your school")
        expect(page).to have_content(school_1.name)
      end
    end
  end

  context 'as a pupil' do
    let(:pupil) { create(:pupil, school: school)}

    before(:each) do
      sign_in(pupil)
      visit activity_type_path(activity_type)
    end

    context 'viewing an activity type' do
      context 'when school is data enabled' do
        it 'should see school specific content' do
          expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to_not have_content(activity_type.description.to_plain_text)
        end

        it 'should not see prompt to login' do
          expect(page).to_not have_link("Sign in to record activity")
        end

        it 'should see prompt to record it' do
          expect(page).to have_content("Complete this activity to score your school #{activity_type.score} points!")
          expect(page).to have_link("Record this activity")
        end
      end

      context 'when school not data enabled' do
        let(:school_data_enabled) { false }

        it 'should see generic content if school if activity is data driven' do
          visit activity_type_path(activity_type)
          expect(page).to_not have_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to have_content(activity_type.description.to_plain_text)
        end

        context 'when activity not data driven' do
          let(:activity_data_driven)  { false }

          it 'should see school specific content' do
            visit activity_type_path(activity_type)
            expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
            expect(page).to_not have_content(activity_type.description.to_plain_text)
          end
        end
      end
    end
  end

  context "displaying prizes" do
    let!(:activity)     { create(:activity, school: school, activity_type: activity_type) }
    let(:feature_active) { false }
    let(:prize_excerpt) { 'Our top scoring schools this year could win' }
    before do
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true) if feature_active
      sign_in(create(:admin))
    end
    context "when activity is complete" do
      before { visit completed_school_activity_path(school, activity) }
      it { expect(page).to_not have_content(prize_excerpt) }
      context "feature is active" do
        let(:feature_active) { true }
        it { expect(page).to have_content(prize_excerpt) }
        it { expect(page).to have_link('read more', href: 'https://blog.energysparks.uk/fantastic-prizes-to-motivate-pupils-to-take-energy-saving-action/') }
      end
    end
  end
end

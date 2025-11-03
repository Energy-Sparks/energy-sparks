# frozen_string_literal: true

require 'rails_helper'

describe 'viewing and recording activities' do
  let!(:activity_category) { create(:activity_category) }
  let!(:audit) {}

  let!(:subject)  { Subject.create(name: 'Science and Technology') }
  let!(:ks1)      { KeyStage.create(name: 'KS1') }

  let(:activity_data_driven)    { true }
  let(:school_data_enabled)     { true }

  let(:activity_type_name) { 'Exciting activity' }
  let(:activity_description) { "It's An #{activity_type_name}" }
  let!(:activity_type) do
    create(:activity_type, name: activity_type_name, activity_category:, description: activity_description,
                           key_stages: [ks1], subjects: [subject], data_driven: activity_data_driven, score: 25)
  end
  let!(:programme) {}

  let!(:scoreboard) { create(:scoreboard) }
  let(:school) { create_active_school(data_enabled: school_data_enabled, scoreboard:) }
  let!(:setup_data) {}

  before do
    SiteSettings.create!(audit_activities_bonus_points: 50)
    create(:national_calendar, title: 'England and Wales') # required for podium to show national placing
  end

  context 'as a public user' do
    before do
      visit activity_type_path(activity_type)
    end

    context 'viewing an activity type' do
      it 'displays title' do
        expect(page).to have_content(activity_type_name)
      end

      it 'displays tags' do
        expect(page).to have_content(ks1.name)
        expect(page).to have_content(subject.name)
      end

      it 'displays score' do
        expect(page).to have_content(activity_type.score)
      end

      it 'displays description' do
        expect(page).to have_content(activity_type.description.to_plain_text)
        expect(page).to have_no_content(activity_type.school_specific_description.to_plain_text)
      end

      it 'displays navigation' do
        expect(page).to have_link("View #{activity_category.activity_types.count} related activity")
      end

      it 'displays resource links' do
        expect(page).to have_content(activity_type.download_links.to_plain_text)
      end

      it 'displays prompt to login' do
        expect(page).to have_content('Are you an Energy Sparks user?')
        expect(page).to have_link('Sign in to record activity')
      end
    end

    context 'when logging in to record' do
      let!(:staff) { create(:staff, school:) }

      it 'redirects back to activity after login' do
        click_on 'Sign in to record activity'
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
    let!(:staff) { create(:staff, school:) }

    before do
      sign_in(staff)
      visit activity_type_path(activity_type)
    end

    context 'viewing an activity type' do
      it 'sees school specific content' do
        expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
        expect(page).to have_no_content(activity_type.description.to_plain_text)
      end

      it 'does not see prompt to login' do
        expect(page).to have_no_link('Sign in to record activity')
      end

      it 'sees prompt to record it' do
        expect(page).to have_content("Complete this activity to score your school #{activity_type.score} points!")
        expect(page).to have_link('Record this activity')
      end
    end

    context 'viewing a previously recorded activity' do
      let!(:activity) { create(:activity, school:, activity_type:) }

      before do
        refresh
      end

      context 'when updating the activity' do
        let(:updated_date) { Date.new(2025, 1, 1) }

        before do
          visit school_activity_path(school, activity)
          click_on 'Edit'
          fill_in :activity_happened_on, with: updated_date.strftime('%d/%m/%Y')
          click_on 'Update activity'
        end

        it 'shows the updates' do
          expect(page).to have_content(activity_type.name)
          expect(page).to have_content(updated_date.strftime('%A, %d %B %Y'))
          activity.reload
          expect(activity.happened_on).to eq(updated_date)
          expect(activity.observations.first.at).to eq(updated_date)
        end
      end

      context 'when school is data enabled' do
        it 'sees previous records' do
          expect(page).to have_content('Activity previously completed')
          expect(page).to have_content('once')
        end

        it 'links to the activity' do
          expect(page).to have_link(href: school_activity_path(school, activity))
        end

        it 'shows school specific description' do
          visit school_activity_path(school, activity)
          expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to have_no_content(activity_type.description.to_plain_text)
        end
      end

      context 'when school not data enabled' do
        let(:school_data_enabled) { false }

        it 'shows generic description' do
          visit school_activity_path(school, activity)
          expect(page).to have_no_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to have_content(activity_type.description.to_plain_text)
        end

        context 'when activity not data driven' do
          let(:activity_data_driven) { false }

          it 'shows school specific description' do
            visit school_activity_path(school, activity)
            expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
            expect(page).to have_no_content(activity_type.description.to_plain_text)
          end
        end
      end
    end

    context 'when recording an activity' do
      let(:activity_description) { 'What we did' }
      let(:today) { Time.zone.today }

      before do
        visit activity_type_path(activity_type)
      end

      context without_feature: :todos do
        let!(:audit) { create(:audit, :with_activity_and_intervention_types, school:) }

        before do
          click_on 'Record this activity'
        end

        it 'shows score and threshold' do
          expect(page).to have_content('Completing this activity up to 10 times this academic year will earn you 25 points')
        end

        it_behaves_like 'a form with a customised trix component', controls: :simple do
          let(:button_size) { :large }
        end

        context 'with non-custom activity' do
          before do
            fill_in :activity_happened_on, with: today.strftime('%d/%m/%Y')
            click_on 'Save activity'
          end

          it_behaves_like 'a task completed page', points: 25, task_type: :activity
          it_behaves_like 'a task completed page with programme complete message', task_type: :activity

          context 'when viewing the activity' do
            before do
              click_on 'View your activity'
            end

            it 'shows activity page' do
              expect(page).to have_content(activity_type_name)
              expect(page).to have_content(today.strftime('%A, %d %B %Y'))
            end
          end
        end

        context 'with custom activity' do
          let(:custom_title) { 'Custom title' }

          let(:other_activity_type_name) { 'Exciting activity (please specify)' }
          let(:activity_type) { create(:activity_type, name: other_activity_type_name, description: nil, custom: true) }

          before do
            fill_in :activity_title, with: custom_title
            fill_in_trix with: activity_description
            fill_in :activity_happened_on, with: today.strftime('%d/%m/%Y')

            click_on 'Save activity'
          end

          it_behaves_like 'a task completed page', points: 25, task_type: :activity
          it_behaves_like 'a task completed page with programme complete message', task_type: :activity

          context 'when viewing the activity' do
            before do
              click_on 'View your activity'
            end

            it 'shows description' do
              expect(page).to have_content(activity_description)
            end

            it 'shows title' do
              expect(page).to have_content(custom_title)
            end
          end
        end

        context 'with previous recordings' do
          before do
            create_list(:activity, 10, activity_type:, school:)
            refresh
          end

          it 'shows message about exceeded threshold' do
            expect(page).to have_content('You have already completed this activity 10 times this academic year. You will not score additional points for recording it')
          end
        end

        context 'on the podium' do
          let!(:other_school) { create(:school, :with_points, score_points: 40, scoreboard:) }
          let!(:time) { today }

          before do
            visit activity_type_path(activity_type)
            click_on 'Record this activity'
            fill_in :activity_happened_on, with: time.strftime('%d/%m/%Y')
            click_on 'Save activity'
          end

          context '0 points' do
            let(:time) { today - 2.years }

            it 'shows the activity completed page' do
              expect(page).to have_content("Congratulations! We've recorded your activity")
            end
          end

          context 'in first place' do
            let(:school) { create(:school, :with_points, score_points: 20, scoreboard:) }

            it 'shows the activity completed page' do
              expect(page).to have_content("Congratulations! You've just scored #{activity_type.score} points")
              expect(page).to have_content('You are in 1st place')
            end
          end

          context 'in second place' do
            let(:school) { create(:school, :with_points, score_points: 5, scoreboard:) }

            it 'shows the activity completed page' do
              expect(page).to have_content("Congratulations! You've just scored #{activity_type.score} points")
              expect(page).to have_content('You are in 2nd place')
            end
          end
        end
      end

      context with_feature: :todos do
        let(:audit) { create(:audit, :with_todos, school:) }

        before do
          click_on 'Record this activity'
        end

        it 'shows score and threshold' do
          expect(page).to have_content('Completing this activity up to 10 times this academic year will earn you 25 points')
        end

        context 'with non-custom activity' do
          before do
            fill_in :activity_happened_on, with: today.strftime('%d/%m/%Y')
            click_on 'Save activity'
          end

          it_behaves_like 'a task completed page', points: 25, task_type: :activity, with_todos: true
          it_behaves_like 'a task completed page with programme complete message', task_type: :activity, with_todos: true

          context 'when viewing the activity' do
            before do
              click_on 'View your activity'
            end

            it 'shows activity page' do
              expect(page).to have_content(activity_type_name)
              expect(page).to have_content(today.strftime('%A, %d %B %Y'))
            end
          end
        end

        context 'with a recording date in a future academic year' do
          let(:next_academic_year) { school.current_academic_year.next_year }
          let(:future_date) { next_academic_year.start_date + 1.day }

          before do
            school.update(calendar: create(:calendar, :with_previous_and_next_academic_years))
            refresh
            fill_in :activity_happened_on, with: future_date.strftime('%d/%m/%Y')
            click_on 'Save activity'
          end

          it_behaves_like 'a task completed page', points: 25, task_type: :activity, with_todos: true do
            let(:future_academic_year) { next_academic_year.title }
          end
        end

        context 'with custom activity' do
          let(:custom_title) { 'Custom title' }

          let(:other_activity_type_name) { 'Exciting activity (please specify)' }
          let(:activity_type) { create(:activity_type, name: other_activity_type_name, description: nil, custom: true) }

          before do
            fill_in :activity_title, with: custom_title
            fill_in_trix with: activity_description
            fill_in :activity_happened_on, with: today.strftime('%d/%m/%Y')

            click_on 'Save activity'
          end

          it_behaves_like 'a task completed page', points: 25, task_type: :activity, with_todos: true
          it_behaves_like 'a task completed page with programme complete message', task_type: :activity, with_todos: true

          context 'when viewing the activity' do
            before do
              click_on 'View your activity'
            end

            it 'shows description' do
              expect(page).to have_content(activity_description)
            end

            it 'shows title' do
              expect(page).to have_content(custom_title)
            end
          end
        end

        context 'with previous recordings' do
          before do
            create_list(:activity, 10, activity_type:, school:)
            refresh
          end

          it 'shows message about exceeded threshold' do
            expect(page).to have_content('You have already completed this activity 10 times this academic year. You will not score additional points for recording it')
          end
        end

        context 'on the podium' do
          let!(:other_school) { create(:school, :with_points, score_points: 40, scoreboard:) }
          let!(:time) { today }

          before do
            visit activity_type_path(activity_type)
            click_on 'Record this activity'
            fill_in :activity_happened_on, with: time.strftime('%d/%m/%Y')
            click_on 'Save activity'
          end

          context '0 points' do
            let(:time) { today - 2.years }

            it 'shows the activity completed page' do
              expect(page).to have_content("Congratulations! We've recorded your activity")
            end
          end

          context 'in first place' do
            let(:school) { create(:school, :with_points, score_points: 20, scoreboard:) }

            it 'shows the activity completed page' do
              expect(page).to have_content("Congratulations! You've just scored #{activity_type.score} points")
              expect(page).to have_content('You are in 1st place')
            end
          end

          context 'in second place' do
            let(:school) { create(:school, :with_points, score_points: 5, scoreboard:) }

            it 'shows the activity completed page' do
              expect(page).to have_content("Congratulations! You've just scored #{activity_type.score} points")
              expect(page).to have_content('You are in 2nd place')
            end
          end
        end
      end
    end
  end

  context 'as a group admin' do
    let!(:group_admin)    { create(:group_admin) }
    let!(:other_school)   { create(:school, name: 'Other School', school_group: group_admin.school_group) }

    before do
      school.update(school_group: group_admin.school_group)
      sign_in(group_admin)
      visit activity_type_path(activity_type)
    end

    context 'viewing an activity type' do
      it 'sees prompt to record it' do
        expect(page).to have_content("Complete this activity on behalf of a school to score #{activity_type.score} points!")
        expect(page).to have_button('Record this activity')
      end

      it 'uses the Activity Type Filter to check for appropriate schools' do
        expect(ActivityTypeFilter).to receive(:new).with(school:).and_call_original
        expect(ActivityTypeFilter).to receive(:new).with(school: other_school).and_call_original
        visit activity_type_path(activity_type)
      end

      it 'redirects to new activity recording page' do
        select other_school.name, from: :school_id
        click_on 'Record this activity'
        expect(page).to have_content('Record a new energy saving activity for your school')
        expect(page).to have_content(other_school.name)
      end
    end

    context 'when recording an activity', toggle_feature: :todos do
      it 'associates activity with correct school from group' do
        select other_school.name, from: :school_id
        click_on 'Record this activity'
        fill_in :activity_happened_on, with: Time.zone.today.strftime('%d/%m/%Y')
        expect { click_on 'Save activity' }.to change(other_school.activities, :count).by(1)
        expect(page).to have_content('Congratulations!')
        expect(other_school.activities.most_recent.first.happened_on).to eq(Time.zone.today)
        expect(other_school.activities.most_recent.first.observations.first.created_by).to eq(group_admin)
      end
    end

    context 'when school is not in group' do
      let(:school_not_in_group) { create(:school) }

      it 'does not allow recording an activity' do
        visit new_school_activity_path(school_not_in_group, activity_type_id: activity_type.id)
        expect(page).to have_content('You are not authorized to access this page')
        expect(page).to have_no_button('Save activity')
      end
    end
  end

  context 'as an admin' do
    let(:admin)       { create(:admin) }
    let!(:school_1)   { create(:school) }
    let!(:school_2)   { create(:school) }

    context 'viewing an activity type', toggle_feature: :todos do
      before do
        sign_in(admin)
        visit activity_type_path(activity_type)
      end

      it 'sees prompt to record it' do
        expect(page).to have_content("Complete this activity on behalf of a school to score #{activity_type.score} points!")
        expect(page).to have_button('Record this activity')
      end

      it 'does not use the Activity Type Filter to check for appropriate schools' do
        expect(ActivityTypeFilter).not_to receive(:new)
        visit activity_type_path(activity_type)
      end

      it 'redirects to new activity recording page' do
        select school_1.name, from: :school_id
        click_on 'Record this activity'
        expect(page).to have_content('Record a new energy saving activity for your school')
        expect(page).to have_content(school_1.name)
      end
    end
  end

  context 'as a pupil' do
    let(:pupil) { create(:pupil, school:) }

    context 'viewing an activity type', toggle_feature: :todos do
      before do
        sign_in(pupil)
        visit activity_type_path(activity_type)
      end

      context 'when school is data enabled' do
        it 'sees school specific content' do
          expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to have_no_content(activity_type.description.to_plain_text)
        end

        it 'does not see prompt to login' do
          expect(page).to have_no_link('Sign in to record activity')
        end

        it 'sees prompt to record it' do
          expect(page).to have_content("Complete this activity to score your school #{activity_type.score} points!")
          expect(page).to have_link('Record this activity')
        end
      end

      context 'when school not data enabled' do
        let(:school_data_enabled) { false }

        it 'sees generic content if school if activity is data driven' do
          visit activity_type_path(activity_type)
          expect(page).to have_no_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to have_content(activity_type.description.to_plain_text)
        end

        context 'when activity not data driven' do
          let(:activity_data_driven) { false }

          it 'sees school specific content' do
            visit activity_type_path(activity_type)
            expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
            expect(page).to have_no_content(activity_type.description.to_plain_text)
          end
        end
      end
    end
  end
end

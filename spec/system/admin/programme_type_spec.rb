require 'rails_helper'

describe 'programme type management', type: :system do
  let!(:school) { create(:school) }
  let!(:admin)  { create(:admin, school: school) }

  context 'when tasklists feature is switched on' do
    before do
      Flipper.enable(:tasklists)
      # enrolment only enabled if targets enabled...
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
    end

    let!(:programme_type) { create(:programme_type, title: 'Test Programme') }
    let!(:activity_type_tasks) { create_list(:tasklist_activity_type_task, 3, tasklist_source: programme_type) }
    let!(:intervention_type_tasks) { create_list(:tasklist_intervention_type_task, 3, tasklist_source: programme_type) }

    context 'editing tasks', :js do
      before do
        sign_in(admin)
        visit edit_admin_programme_type_tasks_path(programme_type)
      end

      it 'lists tasks in order' do
        expect(page).to have_css('#tasklist-activity-types .nested-fields', count: 3)

        displayed_activity_types = all('#tasklist-activity-types .nested-fields')
        activity_type_tasks.each_with_index do |task, idx|
          expect(displayed_activity_types[idx]).to have_content(task.task_source.name)
          expect(displayed_activity_types[idx]).to have_content(task.notes)
        end

        expect(page).to have_css('#tasklist-intervention-types .nested-fields', count: 3)

        displayed_intervention_types = all('#tasklist-intervention-types .nested-fields')
        intervention_type_tasks.each_with_index do |task, idx|
          expect(displayed_intervention_types[idx]).to have_content(task.task_source.name)
          expect(displayed_intervention_types[idx]).to have_content(task.notes)
        end
      end

      context 'when adding tasks' do
        before do
          click_on 'Add activity'
          click_on 'Add action'
        end

        it 'has a good explanation of a test' do
          expect(page).to have_content('activity')
        end
      end

      context 'when moving tasks' do
        context 'moving last activity to first' do
          before do
            handles = all('#tasklist-activity-types .nested-fields .handle')
            handles.last.click
            handles.last.drag_to(handles.first)
          end

          it 'changes activity order to THREE, ONE, TWO' do
            displayed_activities = all('#tasklist-activity-types .nested-fields')

            expect(displayed_activities.first).to have_content(activity_type_tasks.last.notes)
            expect(displayed_activities[1]).to have_content(activity_type_tasks.first.notes)
            expect(displayed_activities.last).to have_content(activity_type_tasks[1].notes)
          end

          context 'when saving' do
            before do
              click_on 'Save'
              accept_alert
              click_on programme_type.title
            end

            it 'saves new order' do
              displayed_activities = page.all('ol.tasklist_activity_types li').map(&:text)

              expect(displayed_activities.first).to have_content(activity_type_tasks.last.task_source.name)
              expect(displayed_activities[1]).to have_content(activity_type_tasks.first.task_source.name)
              expect(displayed_activities.last).to have_content(activity_type_tasks[1].task_source.name)
            end
          end
        end

        context 'moving last action to first' do
          before do
            handles = all('#tasklist-intervention-types .nested-fields .handle')
            handles.last.click
            handles.last.drag_to(handles.first)
          end

          it 'changes action order to THREE, ONE, TWO' do
            displayed_actions = all('#tasklist-intervention-types .nested-fields')

            expect(displayed_actions.first).to have_content(intervention_type_tasks.last.notes)
            expect(displayed_actions[1]).to have_content(intervention_type_tasks.first.notes)
            expect(displayed_actions.last).to have_content(intervention_type_tasks[1].notes)
          end

          context 'when saving' do
            before do
              click_on 'Save'
              accept_alert
              click_on programme_type.title
            end

            it 'saves new order' do
              displayed_tasks = page.all('ol.tasklist_intervention_types li').map(&:text)

              expect(displayed_tasks.first).to have_content(intervention_type_tasks.last.task_source.name)
              expect(displayed_tasks[1]).to have_content(intervention_type_tasks.first.task_source.name)
              expect(displayed_tasks.last).to have_content(intervention_type_tasks[1].task_source.name)
            end
          end
        end
      end
    end
  end

  describe 'managing' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      click_on 'Programme Types'
    end

    it 'allows the user to create, edit and delete a programme type' do
      description = 'SPN1'
      old_title = 'Super programme number 1'
      new_title = 'Super programme number 2'
      bonus_score = 1234
      click_on 'New Programme Type'
      fill_in :programme_type_title_en, with: old_title
      fill_in_trix '#programme_type_description_en', with: description
      attach_file(:programme_type_image_en, Rails.root + 'spec/fixtures/images/placeholder.png')

      click_on 'Save'
      expect(page).to have_content('Programme Types')
      expect(page).to have_content(old_title)
      expect(page).to have_css('.text-danger')
      expect(page).to have_content('No')

      expect(ProgrammeType.last.image_en.filename).to eq('placeholder.png')

      click_on 'Edit'
      fill_in :programme_type_title_en, with: new_title
      fill_in :programme_type_bonus_score, with: bonus_score
      check('Active', allow_label_click: true)
      check('Default', allow_label_click: true)

      click_on 'Save'
      expect(page).to have_content('Programme Types')
      expect(page).to have_content(new_title)
      expect(page).to have_css('.text-success')
      expect(page).to have_content('Yes')

      click_on new_title
      expect(page).to have_content(description)
      expect(page).to have_content(bonus_score)
      click_on 'All programme types'

      click_on 'Delete'
      expect(page).to have_content('There are no programme types')
    end

    context 'when tasklists is switched off' do
      context 'manages order' do
        let!(:activity_category)  { create(:activity_category)}
        let!(:activity_type_1)    { create(:activity_type, name: 'Turn off the lights', activity_category: activity_category) }
        let!(:activity_type_2)    { create(:activity_type, name: 'Turn down the heating', activity_category: activity_category) }
        let!(:activity_type_3)    { create(:activity_type, name: 'Turn down the cooker', activity_category: activity_category) }

        it 'assigns activity types to programme types via a text box position' do
          description = 'SPN1'
          old_title = 'Super programme number 1'

          programme_type = ProgrammeType.create(description: description, title: old_title)

          visit current_path

          click_on 'Edit activities'

          expect(page.find_field('Turn off the light').value).to be_blank
          expect(page.find_field('Turn down the heating').value).to be_blank

          fill_in 'Turn down the heating', with: '1'
          fill_in 'Turn off the lights', with: '2'

          click_on 'Update associated activity type', match: :first
          click_on old_title

          expect(programme_type.activity_types).to match_array([activity_type_2, activity_type_1])
          expect(programme_type.programme_type_activity_types.first.position).to eq(1)
          expect(programme_type.programme_type_activity_types.second.position).to eq(2)

          expect(all('ol.activities li').map(&:text)).to eq ['Turn down the heating', 'Turn off the lights']
        end
      end
    end

    context 'when progammes exist for schools' do
      let!(:activity_type_1)    { create(:activity_type) }
      let!(:activity_type_2)    { create(:activity_type) }
      let!(:programme_type)     { create(:programme_type, activity_types: [activity_type_1, activity_type_2]) }
      let!(:programme)          { create(:programme, school: school, programme_type: programme_type, started_on: Time.zone.today) }
      let!(:activity_1)           { create(:activity, school: school, activity_type: activity_type_1, title: 'Dark now', happened_on: Date.yesterday) }
      let!(:activity_2)           { create(:activity, school: school, activity_type: activity_type_1, title: 'Still dark', happened_on: Time.zone.today) }

      before do
        # enrolment only enabled if targets enabled...
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
      end

      it 'shows links to programmes and progress' do
        visit admin_programme_types_path
        expect(page).to have_content(programme_type.title)
        click_on 'Enrol schools'
        expect(page).to have_content(programme_type.title)
        expect(page).to have_content('Total activities: 2')
        expect(page).to have_content(school.name)
        expect(page).to have_content('started')
        expect(page).to have_content('50 %')
      end

      it 'allows schools to be enrolled if not in the programme already' do
        another_school = create(:school)
        visit admin_programme_type_programmes_path(programme_type)

        # check school already enrolled isn't in dropdown
        expect(page).not_to have_select('programme_school_id', with_options: [school.name])

        select another_school.name, from: :programme_school_id
        click_button 'Enrol'
        expect(page).to have_content("Enrolled #{another_school.name} in #{programme_type.title}")
        expect(another_school.programmes.last.programme_type).to eq(programme_type)
      end
    end
  end
end

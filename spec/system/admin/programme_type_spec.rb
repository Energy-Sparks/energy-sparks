require 'rails_helper'

describe 'programme type management', :include_application_helper, type: :system do
  let!(:school) { create(:school) }
  let!(:admin)  { create(:admin, school: school) }

  before do
    # enrolment only enabled if targets enabled...
    allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
  end

  context 'with todos' do
    let!(:programme_type) { create(:programme_type, title: 'Test Programme') }
    let!(:activity_type_todos) { create_list(:activity_type_todo, 3, assignable: programme_type) }
    let!(:intervention_type_todos) { create_list(:intervention_type_todo, 3, assignable: programme_type) }

    let!(:activity_type) { create(:activity_type) }
    let!(:intervention_type) { create(:intervention_type) }

    context 'viewing programme type admin index' do
      before do
        sign_in(admin)
        visit root_path
        click_on 'Admin'
        click_on 'Programme Types'
      end

      it 'displays a count of activities' do
        expect(page).to have_selector(:table_row, { 'Activities in Programme' => 3 })
      end

      it 'displays a count of actions' do
        expect(page).to have_selector(:table_row, { 'Actions in Programme' => 3 })
      end

      it 'there should be a button to edit activities & actions' do
        expect(page).to have_link('Edit activities & actions')
      end

      context 'when clicking Edit activities and actions button' do
        before do
          click_on 'Edit activities & actions'
        end

        it { expect(page).to have_content('Update the activities and actions') }
      end
    end

    context 'editing tasks', :js do
      before do
        sign_in(admin)
        visit edit_admin_programme_type_todos_path(programme_type)
      end

      it 'lists tasks in order' do
        expect(page).to have_css('#activity-type-todos .nested-fields', count: 3)

        displayed_activity_types = all('#activity-type-todos .nested-fields')
        activity_type_todos.each_with_index do |todo, idx|
          expect(displayed_activity_types[idx]).to have_content(todo.task.name)
          expect(displayed_activity_types[idx]).not_to have_content(todo.notes)
        end

        expect(page).to have_css('#intervention-type-todos .nested-fields', count: 3)

        displayed_intervention_types = all('#intervention-type-todos .nested-fields')
        intervention_type_todos.each_with_index do |todo, idx|
          expect(displayed_intervention_types[idx]).to have_content(todo.task.name)
          expect(displayed_intervention_types[idx]).not_to have_content(todo.notes)
        end
      end

      context 'when adding new tasks' do
        before do
          click_on 'Add activity'
          click_on 'Add action'
        end

        context 'without selecting tasks' do
          before do
            click_on 'Save'
            accept_alert
          end

          it 'displays errors for fields' do
            expect(page).to have_content('Activity must exist')
            expect(page).to have_content('Action must exist')
          end
        end

        context 'when selecting tasks' do
          before do # select new activities and interventions not yet selected
            select_task(:activity_type, activity_type.name, 3)
            select_task(:intervention_type, intervention_type.name, 3)
            click_on 'Save'
            accept_alert
            click_on programme_type.title
          end

          it 'saves new activity type' do
            displayed_tasks = page.all('#activity-type-tasks li').map(&:text)

            expect(displayed_tasks.last).to have_content(activity_type.name)
          end

          it 'saves new intervention type' do
            displayed_tasks = page.all('#intervention-type-tasks li').map(&:text)

            expect(displayed_tasks.last).to have_content(intervention_type.name)
          end
        end
      end

      context 'when moving todos' do
        context 'moving last activity to first' do
          before do
            handles = all('#activity-type-todos .nested-fields .handle')
            handles.last.click
            handles.last.drag_to(handles.first)
          end

          it 'changes activity order to THREE, ONE, TWO' do
            displayed_todos = all('#activity-type-todos .nested-fields')

            expect(displayed_todos[0]).to have_content(activity_type_todos[2].task.name)
            expect(displayed_todos[1]).to have_content(activity_type_todos[0].task.name)
            expect(displayed_todos[2]).to have_content(activity_type_todos[1].task.name)
          end

          context 'when saving' do
            before do
              click_on 'Save'
              accept_alert
              click_on programme_type.title
            end

            it 'saves new order' do
              displayed_tasks = page.all('#activity-type-tasks li').map(&:text)

              expect(displayed_tasks[0]).to have_content(activity_type_todos[2].task.name)
              expect(displayed_tasks[1]).to have_content(activity_type_todos[0].task.name)
              expect(displayed_tasks[2]).to have_content(activity_type_todos[1].task.name)
            end
          end
        end

        context 'moving last action to first' do
          before do
            handles = all('#intervention-type-todos .nested-fields .handle')
            handles.last.click
            handles.last.drag_to(handles.first)
          end

          it 'changes action order to THREE, ONE, TWO' do
            displayed_todos = all('#intervention-type-todos .nested-fields')

            expect(displayed_todos[0]).to have_content(intervention_type_todos[2].task.name)
            expect(displayed_todos[1]).to have_content(intervention_type_todos[0].task.name)
            expect(displayed_todos[2]).to have_content(intervention_type_todos[1].task.name)
          end

          context 'when saving' do
            before do
              click_on 'Save'
              accept_alert
              click_on programme_type.title
            end

            it 'saves new order' do
              displayed_tasks = page.all('#intervention-type-tasks li').map(&:text)

              expect(displayed_tasks[0]).to have_content(intervention_type_todos[2].task.name)
              expect(displayed_tasks[1]).to have_content(intervention_type_todos[0].task.name)
              expect(displayed_tasks[2]).to have_content(intervention_type_todos[1].task.name)
            end
          end
        end
      end
    end
  end

  describe 'Managing programmes' do
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

    context 'when progammes exist for schools' do
      let!(:activity_type_1)    { create(:activity_type) }
      let!(:activity_type_2)    { create(:activity_type) }
      let!(:programme_type)     { create(:programme_type, activity_type_tasks: [activity_type_1, activity_type_2]) }
      let!(:programme)          { create(:programme, school: school, programme_type: programme_type, started_on: Time.zone.today) }
      let!(:activity_1)           { create(:activity, school: school, activity_type: activity_type_1, title: 'Dark now', happened_on: Date.yesterday) }
      let!(:activity_2)           { create(:activity, school: school, activity_type: activity_type_1, title: 'Still dark', happened_on: Time.zone.today) }

      it 'shows links to programmes and progress' do
        visit admin_programme_types_path
        expect(page).to have_content(programme_type.title)
        click_on 'Enrol schools'
        expect(page).to have_content(programme_type.title)
        expect(page).to have_content('Total activities: 2')
        expect(page).to have_content(school.name)
        expect(page).to have_content('started')
        expect(page).to have_content(nice_dates(programme.started_on))
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

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'programme types', :include_application_helper, type: :system do
  let!(:school) { create(:school) }
  let!(:school_admin) { create(:school_admin, school:) }
  let!(:pupil) { create(:pupil, school:) }

  let(:activity) { build(:activity, school:, activity_type:, happened_on: Date.yesterday) }
  let(:observation) { build(:observation, :intervention, school:, intervention_type:, at: Date.yesterday) }

  let(:bonus_points) { 10 }

  shared_examples 'a user enrolling in a programme' do
    before do
      click_on programme_type_1.title
    end

    it 'prompts to start' do
      expect(page).to have_content('You can enrol your school in this programme')
    end

    it 'does not prompt to login' do
      expect(page).to have_no_content('Are you an Energy Sparks user?')
      expect(page).to have_no_link('Sign in now')
    end

    it 'successfully enrols the school' do
      expect do
        click_link 'Start'
      end.to change(Programme, :count).from(0).to(1)
      expect(page).to have_content('You started this programme')
      expect(school.reload.programmes).not_to be_empty
    end
  end

  shared_examples 'a todo list when user is not enrolled' do
    it 'shows activities header' do
      expect(page).to have_selector('h3', text: 'activities')
    end

    it 'lists all the activities' do
      assignable.activity_type_tasks.each do |activity_type|
        expect(page).to have_content(activity_type.name)
        expect(page).to have_link('View activity', href: activity_type_path(activity_type))
      end
    end

    it 'shows the actions header' do
      expect(page).to have_selector('h3', text: 'actions')
    end

    it 'lists all the actions' do
      assignable.intervention_type_tasks.each do |intervention_type|
        expect(page).to have_content(intervention_type.name)
        expect(page).to have_link('View action', href: intervention_type_path(intervention_type))
      end
    end

    context 'when assignable has only activities' do
      before do
        assignable.update(intervention_type_tasks: [])
        refresh
      end

      it 'shows activities header' do
        expect(page).to have_selector('h3', text: 'activities')
      end

      it 'does not show actions header' do
        expect(page).not_to have_selector('h3', text: 'actions')
      end
    end

    it 'does not have checklist' do
      expect(page).to have_no_css('i.fa-circle.text-muted')
      expect(page).to have_no_css('i.fa-circle-check.text-success')
    end
  end

  shared_examples 'a user that has not yet enrolled in a programme' do
    let!(:programme_type) { programme_type_4 }

    context 'user has not completed any tasks' do
      before do
        click_on programme_type.title
      end

      it { expect(page).to have_content('You can enrol your school in this programme') }
      it { expect(page).to have_link('Start') }
    end

    context 'when user has completed one activity' do
      before do
        create(:activity, school:, activity_type: programme_type.activity_types.first, happened_on: Date.yesterday)
        click_on programme_type.title
      end

      it {
        expect(page).to have_content("You've recently completed an activity that is part of this programme. Do you want to enrol in the programme?")
      }

      it { expect(page).to have_link('Start') }
    end

    context 'when user has already completed several activities' do
      before do
        create(:activity, school:, activity_type: programme_type.activity_types.first, happened_on: Date.yesterday)
        create(:activity, school:, activity_type: programme_type.activity_types.second, happened_on: Date.yesterday)
        click_on programme_type.title
      end

      it {
        expect(page).to have_content("You've recently completed 2 activities that are part of this programme. Do you want to enrol in the programme?")
      }

      it { expect(page).to have_link('Start') }
    end

    context 'when user has completed all activities' do
      before do
        programme_type.activity_types.each do |activity_type|
          create(:activity, school:, activity_type:, happened_on: Date.yesterday)
        end

        click_on programme_type.title
      end

      it {
        expect(page).to have_content("You've completed all the activities in this programme. Mark it done to score 10 bonus points?")
      }

      it { expect(page).to have_link('Complete') }

      context 'when programme has no bonus points' do
        let(:bonus_points) { 0 }

        it {
          expect(page).to have_content("You've completed all the activities in this programme. Mark it as complete?")
        }

        it { expect(page).to have_link('Complete') }
      end
    end
  end

  shared_examples 'a user that has not yet enrolled in a programme with todos' do
    let!(:programme_type) { programme_type_4 }

    context 'user has not completed any tasks' do
      before do
        click_on programme_type.title
      end

      it { expect(page).to have_content('You can enrol your school in this programme') }
      it { expect(page).to have_link('Start') }
    end

    context 'when user has completed one activity' do
      before do
        create(:activity, school:, activity_type: programme_type.activity_type_tasks.first, happened_on: Date.yesterday)
        click_on programme_type.title
      end

      it {
        expect(page).to have_content("You've recently completed a task that is part of this programme. Do you want to enrol in the programme?")
      }

      it { expect(page).to have_link('Start') }
    end

    context 'when user has completed one action' do
      before do
        create(:observation, :intervention, school:, intervention_type: programme_type.intervention_type_tasks.first, at: Date.yesterday)
        click_on programme_type.title
      end

      it {
        expect(page).to have_content("You've recently completed a task that is part of this programme. Do you want to enrol in the programme?")
      }

      it { expect(page).to have_link('Start') }
    end

    context 'when user has already completed an activity and an action' do
      before do
        create(:activity, school:, activity_type: programme_type.activity_type_tasks.first, happened_on: Date.yesterday)
        create(:observation, :intervention, school:, intervention_type: programme_type.intervention_type_tasks.first, at: Date.yesterday)
        click_on programme_type.title
      end

      it {
        expect(page).to have_content("You've recently completed 2 tasks that are part of this programme. Do you want to enrol in the programme?")
      }

      it { expect(page).to have_link('Start') }
    end

    context 'when user has completed all tasks' do
      before do
        programme_type.activity_type_tasks.each do |activity_type|
          create(:activity, school:, activity_type:, happened_on: Date.yesterday)
        end
        programme_type.intervention_type_tasks.each do |intervention_type|
          create(:observation, :intervention, school:, intervention_type:, at: Date.yesterday)
        end

        click_on programme_type.title
      end

      it {
        expect(page).to have_content("You've completed all tasks in this programme. Mark it done to score 10 bonus points?")
      }

      it { expect(page).to have_link('Complete') }

      context 'when programme has no bonus points' do
        let(:bonus_points) { 0 }

        it {
          expect(page).to have_content("You've completed all tasks in this programme. Mark it as complete?")
        }

        it { expect(page).to have_link('Complete') }
      end
    end
  end

  shared_examples 'a user that is enrolled in a programme' do
    let(:activity_type) { programme_type_1.activity_types.first }
    let(:intervention_type) { programme_type_1.intervention_types.first }

    before do
      Programmes::Enroller.new(programme_type_1).enrol(school)
      ActivityCreator.new(activity, nil).process
      click_on programme_type_1.title
    end

    it 'says I have started' do
      expect(page).to have_content('You started this programme')
      expect(page).to have_content('Current Progress')
      expect(page).to have_content(nice_dates(school.programmes.first.started_on))
    end

    it 'indicates I have not completed some activities' do
      expect(page).to have_css('i.fa-circle.text-muted')
    end

    it 'indicates I have completed an activity' do
      expect(page).to have_css('i.fa-check-circle.text-success')
      expect(page).to have_content(nice_dates(activity.happened_on))
    end

    it 'doesnt link to activities that are completed' do
      expect(page).to have_content(activity_type.name)
      expect(page).to have_no_link(href: activity_type_path(activity_type))
      expect(page).to have_link(href: activity_type_path(programme_type_1.activity_types.last))
    end

    context 'when restarting' do
      before do
        travel_to 1.day.from_now do # so that programme start times are different
          click_on('Restart')
        end
      end

      it 'returns started programme last' do
        expect(school.programmes.where(programme_type: programme_type_1).order(:started_on).pluck(:status)).to \
          eq %w[abandoned started]
      end
    end

    context 'when viewing the programme types index page' do
      before do
        click_on('View all programmes')
      end

      it 'indicates I am enrolled on list of programmes' do
        expect(page).to have_content('You have already started this programme')
        expect(page).to have_link('Continue', href: programme_type_path(programme_type_1))
        expect(page).to have_link('View', href: programme_type_path(programme_type_3))
      end

      it_behaves_like 'a no active programmes prompt', displayed: false
    end

    context 'after completing the programme' do
      before { programme_type_1.programme_for_school(school).complete! }

      context 'when viewing the programme types index page' do
        before do
          click_on('View all programmes')
        end

        it 'shows a completion message' do
          expect(page).to have_content('You have already completed this programme')
          expect(page).to have_link('View', href: programme_type_path(programme_type_1))
        end

        it_behaves_like 'a no active programmes prompt', displayed: true
      end

      context 'when viewing the programme type page' do
        before { visit programme_type_path(programme_type_1) }

        it 'shows the programme completed' do
          expect(page).to have_content('You completed this programme on')
          expect(page).to have_no_selector(:link_or_button, 'Repeat')
        end

        context 'when repeating' do
          before do
            programme_type_1.programme_for_school(school).update(ended_on: 1.year.ago)
            refresh
            travel_to 1.day.from_now do # so that programme start times are different
              click_on('Repeat')
            end
          end

          it 'returns started programme last' do
            expect(school.programmes.where(programme_type: programme_type_1).order(:started_on).pluck(:status)).to \
              eq %w[completed started]
          end

          it { expect(page).to have_content('You started this programme') }
        end
      end
    end
  end

  shared_examples 'a user that is enrolled in a programme with todos' do
    let(:activity_type) { programme_type_1.activity_type_tasks.first }
    let(:intervention_type) { programme_type_1.intervention_type_tasks.first }

    before do
      Programmes::Enroller.new(programme_type_1).enrol(school)
      click_on programme_type_1.title
    end

    it 'says I have started' do
      expect(page).to have_content('You started this programme')
      expect(page).to have_content(nice_dates(school.programmes.first.started_on))
    end

    it_behaves_like 'a todo list when there is a completable' do
      let(:assignable) { programme_type_1 }
    end

    context 'when restarting' do
      before do
        travel_to 1.day.from_now do # so that programme start times are different
          click_on('Restart')
        end
      end

      it 'returns started programme last' do
        expect(school.programmes.where(programme_type: programme_type_1).order(:started_on).pluck(:status)).to \
          eq %w[abandoned started]
      end
    end

    context 'when viewing the programme types index page' do
      before do
        click_on('View all programmes')
      end

      it 'indicates I am enrolled on list of programmes' do
        expect(page).to have_content('You have already started this programme')
        expect(page).to have_link('Continue', href: programme_type_path(programme_type_1))
        expect(page).to have_link('View', href: programme_type_path(programme_type_3))
      end

      it_behaves_like 'a no active programmes prompt', displayed: false
    end

    context 'after completing the programme' do
      before { programme_type_1.programme_for_school(school).complete! }

      context 'when viewing the programme types index page' do
        before do
          click_on('View all programmes')
        end

        it 'shows a completion message' do
          expect(page).to have_content('You have already completed this programme')
          expect(page).to have_link('View', href: programme_type_path(programme_type_1))
        end

        it_behaves_like 'a no active programmes prompt', displayed: true
      end

      context 'when viewing the programme type page' do
        before { visit programme_type_path(programme_type_1) }

        it 'shows the programme completed' do
          expect(page).to have_content('You completed this programme on')
          expect(page).to have_no_selector(:link_or_button, 'Repeat')
        end

        context 'when repeating' do
          before do
            programme_type_1.programme_for_school(school).update(ended_on: 1.year.ago)
            refresh
            travel_to 1.day.from_now do # so that programme start times are different
              click_on('Repeat')
            end
          end

          it 'returns started programme last' do
            expect(school.programmes.where(programme_type: programme_type_1).order(:started_on).pluck(:status)).to \
              eq %w[completed started]
          end

          it { expect(page).to have_content('You started this programme') }
        end
      end
    end
  end

  #### TESTS START HERE #####

  context without_feature: :todos do
    let!(:programme_type_1) { create(:programme_type_with_activity_types) }
    let!(:programme_type_2) { create(:programme_type, active: false) }
    let!(:programme_type_3) { create(:programme_type) }
    let!(:programme_type_4) { create(:programme_type_with_activity_types, bonus_score: bonus_points) }

    context 'as a public user' do
      before do
        visit programme_types_path
      end

      it 'displays summary of programmes' do
        expect(page).to have_content(programme_type_1.title)
        expect(page).to have_content(programme_type_1.short_description)
      end

      it 'shows only active programme types' do
        expect(page).to have_content(programme_type_1.title)
        expect(page).to have_content(programme_type_3.title)
        expect(page).to have_no_content(programme_type_2.title)
      end

      context 'viewing a programme type' do
        before do
          click_on programme_type_1.title
        end

        it 'displays the programme overview' do
          expect(page).to have_content(programme_type_1.title)
          expect(page).to have_content(programme_type_1.short_description)
          expect(page).to have_content(programme_type_1.description.body.to_plain_text)
          expect(page).to have_link(href: programme_type_1.document_link)
        end

        it 'lists all the activities' do
          programme_type_1.activity_types.each do |activity_type|
            expect(page).to have_link(activity_type.name, href: activity_type_path(activity_type))
          end
        end

        it 'does not have checklist' do
          expect(page).to have_no_css('i.fa-circle.text-muted')
          expect(page).to have_no_css('i.fa-circle.text-success')
        end

        it 'does not prompt to start' do
          expect(page).to have_no_content('You can enrol your school in this programme')
        end

        it 'prompts to login' do
          expect(page).to have_content('Are you an Energy Sparks user?')
          expect(page).to have_link('Sign in now')
        end

        context 'when logging in to enrol' do
          let!(:staff) { create(:staff, school:) }

          it 'redirects back to programme after login' do
            click_on 'Sign in now'
            fill_in 'Email', with: staff.email
            fill_in 'Password', with: staff.password
            within '#staff' do
              click_on 'Sign in'
            end
            expect(page).to have_content(programme_type_1.title)
            expect(page).to have_content('You can enrol your school in this programme')
          end
        end

        context 'when programme type is not active' do
          before do
            visit programme_type_path(programme_type_2)
          end

          it { expect(page).to have_content('Page not found') }
        end
      end
    end

    context 'as a school admin' do
      before do
        sign_in school_admin
        visit programme_types_path
      end

      it_behaves_like 'a no active programmes prompt'
      it_behaves_like 'a user enrolling in a programme'
      it_behaves_like 'a user that has not yet enrolled in a programme'
      it_behaves_like 'a user that is enrolled in a programme'
    end

    context 'as a pupil' do
      before do
        sign_in pupil
        visit programme_types_path
      end

      it_behaves_like 'a no active programmes prompt'
      it_behaves_like 'a user enrolling in a programme'
      it_behaves_like 'a user that has not yet enrolled in a programme'
      it_behaves_like 'a user that is enrolled in a programme'
    end
  end

  context with_feature: :todos do
    let!(:programme_type_1) { create(:programme_type, :with_todos) }
    let!(:programme_type_2) { create(:programme_type, :with_todos, active: false) }
    let!(:programme_type_3) { create(:programme_type, :with_todos) }
    let!(:programme_type_4) { create(:programme_type, :with_todos, bonus_score: bonus_points) }
    let!(:programme_type_empty) { create(:programme_type) }
    let!(:programme_type_activities) { create(:programme_type, :with_activity_type_todos) }
    let!(:programme_type_actions) { create(:programme_type, :with_intervention_type_todos) }

    context 'as a public user' do
      before do
        visit programme_types_path
      end

      it 'displays summary of programmes' do
        expect(page).to have_content(programme_type_1.title)
        expect(page).to have_content(programme_type_1.short_description)
      end

      it 'shows only active programme types' do
        expect(page).to have_content(programme_type_1.title)
        expect(page).to have_content(programme_type_3.title)
        expect(page).to have_no_content(programme_type_2.title)
      end

      it 'does not show programme types without todos' do
        expect(page).to have_no_content(programme_type_empty.title)
      end

      context 'viewing activity only programme type' do
        before do
          click_on programme_type_activities.title
        end

        it { expect(page).to have_content('This programme is intended for pupils')}
      end

      context 'viewing action only programme type' do
        before do
          click_on programme_type_actions.title
        end

        it { expect(page).to have_content('This programme is intended for adults')}
      end

      context 'viewing a programme type' do
        before do
          click_on programme_type_1.title
        end

        it 'displays the programme overview' do
          expect(page).to have_content(programme_type_1.title)
          expect(page).to have_content(programme_type_1.short_description)
          expect(page).to have_content(programme_type_1.description.body.to_plain_text)
          expect(page).to have_link(href: programme_type_1.document_link)
          expect(page).to have_content('This programme is intended for the whole school')
        end

        it_behaves_like 'a todo list when user is not enrolled' do
          let(:assignable) { programme_type_1 }
        end

        it 'does not prompt to start' do
          expect(page).to have_no_content('You can enrol your school in this programme')
        end

        it 'prompts to login' do
          expect(page).to have_content('Are you an Energy Sparks user?')
          expect(page).to have_link('Sign in now')
        end

        context 'when logging in to enrol' do
          let!(:staff) { create(:staff, school:) }

          it 'redirects back to programme after login' do
            click_on 'Sign in now'
            fill_in 'Email', with: staff.email
            fill_in 'Password', with: staff.password
            within '#staff' do
              click_on 'Sign in'
            end
            expect(page).to have_content(programme_type_1.title)
            expect(page).to have_content('You can enrol your school in this programme')
          end
        end

        context 'when programme type is not active' do
          before do
            visit programme_type_path(programme_type_2)
          end

          it { expect(page).to have_content('Page not found') }
        end
      end
    end

    context 'as a school admin' do
      before do
        sign_in school_admin
        visit programme_types_path
      end

      it_behaves_like 'a no active programmes prompt'
      it_behaves_like 'a user enrolling in a programme'
      it_behaves_like 'a user that has not yet enrolled in a programme with todos'
      it_behaves_like 'a user that is enrolled in a programme with todos'
    end

    context 'as a pupil' do
      before do
        sign_in pupil
        visit programme_types_path
      end

      it_behaves_like 'a no active programmes prompt'
      it_behaves_like 'a user enrolling in a programme'
      it_behaves_like 'a user that has not yet enrolled in a programme with todos'
      it_behaves_like 'a user that is enrolled in a programme with todos'
    end
  end
end

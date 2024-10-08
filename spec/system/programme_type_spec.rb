# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'programme types', :include_application_helper do
  let!(:school) { create(:school) }
  let!(:school_admin) { create(:school_admin, school:) }
  let!(:pupil) { create(:pupil, school:) }

  let!(:programme_type_1) { create(:programme_type_with_activity_types) }
  let!(:programme_type_2) { create(:programme_type, active: false) }
  let!(:programme_type_3) { create(:programme_type) }
  let(:bonus_points) { 10 }
  let!(:programme_4) { create(:programme_type_with_activity_types, bonus_score: bonus_points) }

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

  shared_examples 'a user that has not yet enrolled in a programme' do
    let!(:programme) { programme_4 }

    context 'user has not completed any activities' do
      before do
        click_on programme.title
      end

      it { expect(page).to have_content('You can enrol your school in this programme') }
      it { expect(page).to have_link('Start') }
    end

    context 'when user has completed one activity' do
      before do
        create(:activity, school:, activity_type: programme.activity_types.first, happened_on: Date.yesterday)
        click_on programme.title
      end

      it {
        expect(page).to have_content("You've recently completed an activity that is part of this programme. Do you want to enrol in the programme?")
      }

      it { expect(page).to have_link('Start') }
    end

    context 'when user has several activities' do
      before do
        create(:activity, school:, activity_type: programme.activity_types.first, happened_on: Date.yesterday)
        create(:activity, school:, activity_type: programme.activity_types.second, happened_on: Date.yesterday)
        click_on programme.title
      end

      it {
        expect(page).to have_content("You've recently completed 2 activities that are part of this programme. Do you want to enrol in the programme?")
      }

      it { expect(page).to have_link('Start') }
    end

    context 'when user has completed all activities' do
      before do
        programme.activity_types.each do |activity_type|
          create(:activity, school:, activity_type:, happened_on: Date.yesterday)
        end
        click_on programme.title
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

  shared_examples 'a user that is enrolled in a programme' do
    let(:activity_type) { programme_type_1.activity_types.first }
    let(:activity)      { create(:activity, school:, activity_type:, happened_on: Date.yesterday) }

    before do
      # this is because the Enroller relies on this currently
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
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

    it 'allows restarting' do
      click_on('Restart')
      expect(school.programmes.where(programme_type: programme_type_1).order(:started_on).pluck(:status)).to \
        eq %w[abandoned started]
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

        it 'allows repetition' do
          programme_type_1.programme_for_school(school).update(ended_on: 1.year.ago)
          refresh
          click_on('Repeat')
          expect(school.programmes.where(programme_type: programme_type_1).order(:started_on).pluck(:status)).to \
            eq %w[completed started]
          expect(page).to have_content('You started this programme')
        end
      end
    end
  end

  #### TESTS START HERE #####

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
        programme_type_1.activity_types.each do |at|
          expect(page).to have_link(at.name, href: activity_type_path(at))
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

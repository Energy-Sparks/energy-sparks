# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'scoreboards', :scoreboards do
  let(:calendar) { create(:national_calendar, :with_previous_and_next_academic_years, title: 'England and Wales') }
  let(:scoreboard) { create(:scoreboard, name: 'Super scoreboard', academic_year_calendar: calendar) }
  let!(:school) { create(:school, :with_school_group, scoreboard: scoreboard, name: 'No points', calendar: calendar) }
  let(:points) { 123 }
  let!(:school_with_points) do
    create(:school, :with_points, score_points: points, scoreboard: scoreboard, calendar: calendar)
  end

  # Avoids problem with showing national placing. National Scoreboard only runs from
  # 1st Sept to 31st Jul.
  around do |example|
    travel_to Date.new(2024, 4, 1) do
      example.run
    end
  end

  describe 'with public scoreboards', :aggregate_failures do
    describe 'on the index page' do
      before do
        visit scoreboards_path
      end

      it 'allows anyone to see the scoreboard' do
        expect(page).to have_content('Super scoreboard')
        expect(page).to have_link(href: scoreboard_path(scoreboard))
        expect(page).to have_content(school_with_points.name)
      end

      it 'has a national scoreboard' do
        expect(page).to have_content('National Scoreboard')
        expect(page).to have_link(href: scoreboard_path('national'))
      end

      it 'includes top ranking schools' do
        expect(page).to have_content(school_with_points.name)
        expect(page).to have_content(points)
        expect(page).to have_no_content(school.name)
        expect(page).to have_link('View scores for 2 schools')
      end
    end

    it 'includes schools and points on the scoreboard' do
      visit scoreboard_path(scoreboard)
      expect(page).to have_content('Super scoreboard')
      expect(page).to have_content(school_with_points.name)
      expect(page).to have_link(points.to_s, href: school_timeline_path(school_with_points, academic_year: scoreboard.this_academic_year))
      expect(page).to have_content(points)
      expect(page).to have_content(school.name)
      expect(page).to have_content('0')
    end

    it 'shows schools and points on the national scoreboard' do
      visit scoreboard_path('national')
      expect(page).to have_content('National Scoreboard')
      expect(page).to have_content(school_with_points.name)
      expect(page).to have_content(points)
      expect(page).to have_link(points.to_s, href: school_timeline_path(school_with_points))
      expect(page).to have_link('last year', href: scoreboard_path('national', previous_year: true))
      expect(page).to have_no_content(school.name)
    end

    it 'redirects all to national' do
      visit scoreboard_path('all')
      expect(page).to have_current_path(scoreboard_path('national'))
    end
  end

  describe 'with private scoreboards' do
    let!(:private_scoreboard) { create(:scoreboard, name: 'Private scoreboard', public: false) }
    let!(:other_school) { create(:school, :with_school_group, scoreboard: private_scoreboard) }

    it 'doesn\'t list the scoreboard' do
      visit schools_path
      within '#our-schools' do
        click_on 'Scoreboards'
      end
      expect(page).to have_content('Super scoreboard')
      expect(page).to have_no_content('Private scoreboard')
    end

    it 'doesn\'t allow access to the private scoreboard' do
      visit scoreboard_path(private_scoreboard)
      expect(page).to have_content('You are not authorized to access this page')
    end

    describe 'when logged in as user from school linked to scoreboard' do
      let!(:user)         { create(:staff, school: other_school) }

      before do
        sign_in(user)
      end

      it 'can view the public and private boards' do
        visit scoreboards_path
        expect(page).to have_content('Super scoreboard')
        expect(page).to have_content('Private scoreboard')
        expect(page).to have_link(href: scoreboard_path(private_scoreboard))
        visit scoreboard_path(private_scoreboard)
        expect(page).to have_content('Private scoreboard')
        expect(page).to have_content(other_school.name)
      end
    end
  end

  context 'displaying prizes' do
    let(:feature_active) { false }
    let(:prize_excerpt) { 'We are also offering a special prize' }

    around do |example|
      ClimateControl.modify FEATURE_FLAG_SCOREBOARD_PRIZES: feature_active.to_s do
        example.run
      end
    end

    context 'on index page' do
      before { visit scoreboards_path }

      it { expect(page).to have_no_content(prize_excerpt) }

      context 'feature is active' do
        let(:feature_active) { true }

        it { expect(page).to have_content(prize_excerpt) }
        it { expect(page).to have_link('read more', href: 'https://blog.energysparks.uk/fantastic-prizes-to-motivate-pupils-to-take-energy-saving-action/') }
      end
    end

    context 'on scoreboard page' do
      before { visit scoreboards_path(scoreboard) }

      it { expect(page).to have_no_content(prize_excerpt) }

      context 'feature is active' do
        let(:feature_active) { true }

        it { expect(page).to have_content(prize_excerpt) }
        it { expect(page).to have_link('read more', href: 'https://blog.energysparks.uk/fantastic-prizes-to-motivate-pupils-to-take-energy-saving-action/') }
      end
    end
  end
end

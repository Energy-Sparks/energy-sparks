require 'rails_helper'

describe 'timelines', type: :system do
  # rubocop:disable RSpec/MultipleMemoizedHelpers

  let(:user) { nil }
  let(:schools) { [] }

  let!(:observations_by_year) do # create observations for this year, last year and 3 years ago, for each school
    [0, 1, 3].collect do |i|
      schools.collect do |school|
        create(:observation, :activity, school:, at: i.years.ago)
      end
    end
  end

  shared_examples 'a timeline' do |show_school: false|
    it 'shows recent observations in table' do
      within('.table') do
        observations_by_year.first.each do |observation|
          expect(page).to have_content(observation.activity.display_name)
          expect(page).to have_content(observation.points)
          expect(page).to have_content(observation.at.to_fs(:es_short))
        end
      end
    end

    it 'does show school name in table', if: show_school do
      within('.table') do
        schools.each do |school|
          expect(page).to have_content(school.name)
        end
      end
    end

    it 'does not show school name in table', unless: show_school do
      within('.table') do
        schools.each do |school|
          expect(page).not_to have_content(school.name)
        end
      end
    end

    it 'does not show old observations' do
      observations_by_year.second.each do |observation|
        expect(page).not_to have_content(observation.activity.display_name)
      end
      observations_by_year.last.each do |observation|
        expect(page).not_to have_content(observation.activity.display_name)
      end
    end

    it 'shows links to previous years, including missing ones' do
      [0, 1, 2, 3].each do |i|
        expect(page).to have_link("#{i.years.ago.year} - #{(i - 1).years.ago.year}")
      end
    end

    it 'shows a count of observations per year' do
      expect(page).to have_link("(#{schools.count})", count: 3)
    end

    it 'shows a count of zero for years with no observations' do
      expect(page).to have_link('(0)', count: 1)
    end

    context 'when clicking on a previous year' do
      before do
        click_on("#{1.year.ago.year} - #{Time.zone.today.year}")
      end

      it 'shows observations from that year' do
        within('.table') do
          observations_by_year.second.each do |observation|
            expect(page).to have_content(observation.activity.display_name)
          end
        end
      end

      it 'does not show observations from other years' do
        within('.table') do
          observations_by_year.first.each do |observation|
            expect(page).not_to have_content(observation.activity.display_name)
          end

          observations_by_year.last.each do |observation|
            expect(page).not_to have_content(observation.activity.display_name)
          end
        end
      end
    end
  end

  describe 'school timeline' do
    let(:data_sharing) { }
    let(:calendar) { create(:calendar, :for_school, previous_academic_year_count: 3) }
    let(:school) { create(:school, calendar:, data_sharing:, school_group: create(:school_group), visible: true)}
    let!(:schools) { [school] }

    before do
      sign_in(user) if user
      visit school_timeline_path(schools.first)
    end

    context 'when school is public' do
      let(:data_sharing) { :public }

      context 'when not logged in' do
        let(:user) { nil }

        it_behaves_like 'a timeline', show_school: false
      end
    end

    context 'when data_sharing is private' do
      let(:data_sharing) { :private }

      context 'when not logged in' do
        let(:user) { nil }

        it { expect(page).to have_content('has no public data') }
      end

      context 'when user is school admin to a school in same group' do
        let(:user) { create(:school_admin, school: create(:school, school_group: school.school_group)) }

        it { expect(page).to have_content('has no public data') }
      end
    end

    context 'when data_sharing is within_group' do
      let(:data_sharing) { :within_group }

      context 'when not logged in' do
        let(:user) { nil }

        it { expect(page).to have_content('has no public data') }
      end

      context 'when user is school admin to a school in same group' do
        let(:user) { create(:school_admin, school: create(:school, school_group: school.school_group)) }

        it_behaves_like 'a timeline', show_school: false
      end
    end
  end

  describe 'school group timeline' do
    let(:public) { true }
    let(:calendar) { create(:national_calendar, :with_academic_years, previous_academic_year_count: 3) }
    let(:school_group) { create(:school_group, default_template_calendar: calendar, public:) }

    before do
      sign_in(user) if user
      visit school_group_timeline_path(school_group)
    end

    context 'when not logged in' do
      context 'when school group is public' do
        let!(:schools) { create_list(:school, 2, school_group:) }
        let(:public) { true }

        it_behaves_like 'a timeline', show_school: true
      end

      context 'when school group is private' do
        let(:public) { false }

        it_behaves_like 'shows the we are working with message'
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end

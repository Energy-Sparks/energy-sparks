require 'rails_helper'

describe 'timelines' do
  before { travel_to(Date.new(2025, 12, 31)) }

  let(:schools) { [] }
  let!(:observations) do
    {
      # create observations for this year, last year and 3 years ago, for each school
      by_year: [0, 1, 3].map { |i| schools.map { |school| create(:observation, :activity, school:, at: i.years.ago) } },
      # create invisible observations for current year
      invisible: create(:observation, :activity, school: schools.first, at: Time.current, visible: false)
    }
  end

  shared_examples 'a timeline' do |show_school: false|
    let(:academic_year) { calendar.national_calendar.current_academic_year }

    it 'shows summary' do
      expect(page).to have_content("Showing 1 - #{schools.count} of #{schools.count} " \
                                   "activities recorded between #{academic_year.start_date.to_fs(:es_long)} " \
                                   "and #{Time.zone.today.to_fs(:es_long)}")
    end

    it 'shows recent observations in table' do
      within('.table') do
        observations[:by_year].first.each do |observation|
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
          expect(page).to have_no_content(school.name)
        end
      end
    end

    it 'does not show old observations' do
      observations[:by_year].second.each do |observation|
        expect(page).to have_no_content(observation.activity.display_name)
      end
      observations[:by_year].last.each do |observation|
        expect(page).to have_no_content(observation.activity.display_name)
      end
    end

    it 'does not show invisible observations' do
      expect(page).to have_no_content(observations[:invisible].activity.display_name)
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
      let(:previous_academic_year) { calendar.national_calendar.academic_years.ordered[-2] }

      before do
        click_on("#{previous_academic_year.start_date.year} - #{previous_academic_year.end_date.year}")
      end

      it 'shows summary' do
        expect(page).to have_content("Showing 1 - #{schools.count} of #{schools.count} activities recorded between #{previous_academic_year.start_date.to_fs(:es_long)} and #{previous_academic_year.end_date.to_fs(:es_long)}")
      end

      it 'shows observations from that year' do
        within('.table') do
          observations[:by_year].second.each do |observation|
            expect(page).to have_content(observation.activity.display_name)
          end
        end
      end

      it 'does not show observations from other years' do
        within('.table') do
          observations[:by_year].first.each do |observation|
            expect(page).to have_no_content(observation.activity.display_name)
          end

          observations[:by_year].last.each do |observation|
            expect(page).to have_no_content(observation.activity.display_name)
          end
        end
      end
    end
  end

  describe 'school timeline' do
    let(:data_sharing) {}
    let(:calendar) { create(:calendar, :for_school, previous_academic_year_count: 3) }
    let(:schools) { [create(:school, calendar:, data_sharing:, school_group: create(:school_group), visible: true)] }

    def school
      schools.first
    end

    def school_group
      school.school_group
    end

    def visit_timeline(user: false)
      sign_in(create(:school_admin, school: create(:school, school_group:))) if user
      visit school_timeline_path(school)
    end

    before { visit_timeline }

    context 'when school is public' do
      let(:data_sharing) { :public }

      context 'when not logged in' do
        it_behaves_like 'a timeline', show_school: false
      end
    end

    context 'when data_sharing is private' do
      let(:data_sharing) { :private }

      context 'when not logged in' do
        it { expect(page).to have_content('has no public data') }
      end

      context 'when user is school admin to a school in same group' do
        before { visit_timeline(user: true) }

        it { expect(page).to have_content('has no public data') }
      end
    end

    context 'when data_sharing is within_group' do
      let(:data_sharing) { :within_group }

      context 'when not logged in' do
        it { expect(page).to have_content('has no public data') }
      end

      context 'when user is school admin to a school in same group' do
        before { visit_timeline(user: true) }

        it_behaves_like 'a timeline', show_school: false
      end
    end
  end

  describe 'school group timeline' do
    let(:public) { true }
    let!(:calendar) { create(:national_calendar, :with_academic_years, previous_academic_year_count: 3) }
    let(:school_group) { create(:school_group, default_template_calendar: calendar, public:) }
    let!(:schools) { create_list(:school, 2, school_group:) }

    before { visit school_group_timeline_path(school_group) }

    context 'when not logged in' do
      context 'when school group is public' do
        let(:public) { true }

        it_behaves_like 'a timeline', show_school: true
      end

      context 'when school group is private' do
        let(:public) { false }

        it_behaves_like 'an access controlled group page' do
          let(:path) { school_group_path(school_group) }
        end
      end
    end

    context 'when school group does not have calendars available' do
      let(:calendar) do
        create(:national_calendar, :with_academic_years, previous_academic_year_count: 3, title: 'England and Wales')
      end
      let(:school_group) { create(:school_group, default_template_calendar: nil, public:) }

      it_behaves_like 'a timeline', show_school: true
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end

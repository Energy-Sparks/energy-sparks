# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactReports::Engagement::FeaturedSchoolComponent, :include_application_helper, :include_url_helpers,
               type: :component do
  # Stick inside the national calendar
  # The podium counts it's points from within the national scoreboard calendar. Which is 1st Sept to 30th June.
  before { travel_to Time.zone.local(2026, 5) }

  let(:school_group) { create(:school_group) }
  let!(:config) { create(:impact_report_configuration, school_group: school_group) }
  let(:school) { create(:school, :with_school_group, school_group: school_group) }
  let(:yesterday) { 1.day.ago }

  context 'without override' do
    context 'with activities and actions' do
      before do
        create_list(:activity, 2, school: school, happened_on: yesterday)
        create_list(:observation, 2, :intervention, school: school, at: yesterday)
        render_inline(described_class.new(school_group: school_group))
      end

      it { expect(page).to have_css('#engagement-featured') }
      it { expect(page).to have_text('Featured school') }
      it { expect(page).to have_text(school.name) }
      it { expect(page).to have_text('scoring 110 points') }
      it { expect(page).to have_link('View dashboard', href: school_path(school)) }
      it { expect(page).to have_css('.bg-white.p-4.rounded-3') }
    end

    context 'with a single action and no activities recorded' do
      before do
        create(:observation, :intervention, school: school, at: yesterday)
        render_inline(described_class.new(school_group: school_group))
      end

      it { expect(page).to have_text('scoring 30 points') }
    end

    context 'with a single activity and no actions recorded' do
      before do
        create(:activity, school: school, happened_on: yesterday)
        render_inline(described_class.new(school_group: school_group))
      end

      it { expect(page).to have_text('scoring 25 points') }
    end

    context 'with an action this academic year and an unscored activity in the previous academic year' do
      before do
        create(:observation, :intervention, school: school, at: yesterday)
        create(:activity, school: school, happened_on: 11.months.ago)
        render_inline(described_class.new(school_group: school_group))
      end

      it { expect(page).to have_text('scoring 30 points') }
    end

    context 'with more all-time points at another school' do
      let!(:most_active_school) do
        create(:school, :with_points, score_points: 10, school_group: school_group, activities_happened_on: yesterday)
      end

      let!(:previously_active_school) do
        travel_to(13.months.ago) do
          create(:school, :with_points, score_points: 100, school_group: school_group,
                                        activities_happened_on: Time.zone.today)
        end
      end

      before do
        render_inline(described_class.new(school_group: school_group))
      end

      it 'selects the school with the most points in the last 12 months' do
        expect(previously_active_school.observations.sum(:points)).to eq(100)
        expect(described_class.new(school_group: school_group).default_school).to eq(most_active_school)
      end

      it 'displays the recent points total' do
        expect(page).to have_text('scoring 10 points')
      end
    end

    context 'with no points' do
      before do
        render_inline(described_class.new(school_group: school_group))
      end

      it { expect(rendered_content).to be_blank }
    end

    context 'with points only outside the last 12 months' do
      let!(:previously_active_school) do
        travel_to(13.months.ago) do
          create(:school, :with_points, score_points: 100, school_group: school_group,
                                        activities_happened_on: Time.zone.today)
        end
      end

      before do
        render_inline(described_class.new(school_group: school_group))
      end

      it 'does not select a school' do
        expect(previously_active_school.observations.sum(:points)).to eq(100)
        expect(described_class.new(school_group: school_group).default_school).to be_nil
      end

      it { expect(rendered_content).to be_blank }
    end
  end

  context 'with override' do
    let(:override_school) { create(:school, school_group: school_group) }
    let(:override_description) { 'Custom engagement description' }

    before do
      config.update(
        engagement_school: override_school,
        engagement_note: override_description,
        engagement_school_expiry_date: 1.year.from_now
      )
      render_inline(described_class.new(school_group: school_group))
    end

    it { expect(page).to have_text(override_description) }
    it { expect(page).to have_link('View dashboard', href: school_path(override_school)) }
    it { expect(page).to have_css('img') }
  end

  context 'with override but expired' do
    let(:override_school) { create(:school, school_group: school_group) }

    before do
      create_list(:observation, 1, :intervention, school: school, at: yesterday)

      config.update!(
        engagement_note: 'Note',
        engagement_school: override_school,
        engagement_school_expiry_date: yesterday
      )
      render_inline(described_class.new(school_group: school_group))
    end

    it { expect(page).to have_text('scoring 30 points') }
    it { expect(page).to have_css('.scoreboards-podium-component') }
  end

  context 'when school is not present' do
    let(:school_group) { create(:school_group) }
    let!(:config) { create(:impact_report_configuration, school_group: school_group) }

    before do
      allow(school_group).to receive(:scored_schools).and_return(ScoredSchoolsList.new([]))
      render_inline(described_class.new(school_group: school_group))
    end

    it 'does not render' do
      expect(rendered_content).to be_blank
    end
  end
end

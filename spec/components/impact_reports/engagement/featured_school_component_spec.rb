# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactReports::Engagement::FeaturedSchoolComponent, :include_application_helper, :include_url_helpers,
               type: :component do
  let(:school_group) { create(:school_group) }
  let(:html) do
    render_inline(described_class.new(school_group: school_group))
  end
  let!(:config) { create(:impact_report_configuration, school_group: school_group) }
  let(:school) { create(:school, :with_school_group, school_group: school_group) }

  before do
    create_list(:observation, 3, :activity, school: school)
    school.reload
  end

  context 'without override' do
    it { expect(html).to have_css('#engagement-featured') }
    it { expect(html).to have_text(school.name) }
    it { expect(html).to have_link('View dashboard', href: school_path(school)) }
    it { expect(html).to have_css('.bg-white.p-4.rounded-3') }
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
    end

    it { expect(html).to have_text(override_description) }
    it { expect(html).to have_link('View dashboard', href: school_path(override_school)) }
    it { expect(html).to have_css('img') }
  end

  context 'with override but expired' do
    let(:override_school) { create(:school, school_group: school_group) }

    before do
      config.update(
        engagement_school: override_school,
        engagement_school_expiry_date: 1.day.ago
      )
    end

    it { expect(html).to have_text(school.name) }
  end

  context 'when school is not present' do
    let(:school_group) { create(:school_group) }
    let!(:config) { create(:impact_report_configuration, school_group: school_group) }

    before do
      allow(school_group).to receive(:scored_schools).and_return([])
    end

    it 'does not render' do
      expect(render_inline(described_class.new(school_group: school_group)).to_html).to be_blank
    end
  end
end

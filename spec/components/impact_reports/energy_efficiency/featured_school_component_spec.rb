# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactReports::EnergyEfficiency::FeaturedSchoolComponent, :include_application_helper,
               :include_url_helpers, type: :component do
  let(:school_group) { create(:school_group) }
  let!(:config) { create(:impact_report_configuration, school_group: school_group) }

  context 'without override' do
    let(:html) do
      render_inline(described_class.new(school_group: school_group))
    end

    it { expect(html).to have_no_css('#energy-efficiency-featured') }
  end

  context 'with override' do
    let(:featured_school) { create(:school, school_group: school_group) }
    let(:html) do
      render_inline(described_class.new(school_group: school_group))
    end
    let(:custom_description) { 'Custom energy efficiency description' }

    before do
      config.update(
        energy_efficiency_school: featured_school,
        energy_efficiency_note: custom_description,
        energy_efficiency_school_expiry_date: 1.year.from_now
      )
    end

    it { expect(html).to have_css('#energy-efficiency-featured') }
    it { expect(html).to have_content(custom_description) }
    it { expect(html).to have_link('View dashboard', href: school_path(featured_school)) }
  end

  context 'with override and custom image' do
    let(:featured_school) { create(:school, school_group: school_group) }
    let(:html) do
      render_inline(described_class.new(school_group: school_group))
    end

    before do
      config.update(
        energy_efficiency_school: featured_school,
        energy_efficiency_note: 'Note',
        energy_efficiency_school_expiry_date: 1.year.from_now
      )
      config.energy_efficiency_image.attach(
        io: Rails.root.join('app/assets/images/for-multi-academies.jpg').open, filename: 'for-multi-academies.jpg'
      )
    end

    it { expect(html).to have_css('img') }
  end

  context 'with override but expired' do
    let(:featured_school) { create(:school, school_group: school_group) }
    let(:html) do
      render_inline(described_class.new(school_group: school_group))
    end

    before do
      config.update(
        energy_efficiency_school: featured_school,
        energy_efficiency_school_expiry_date: 1.day.ago
      )
    end

    it { expect(html).to have_no_css('#energy-efficiency-featured') }
  end

  context 'when school is not present' do
    let(:school_group) { create(:school_group) }
    let!(:config) { create(:impact_report_configuration, school_group: school_group, energy_efficiency_school: nil) }

    it 'does not render' do
      expect(render_inline(described_class.new(school_group: school_group)).to_html).to be_blank
    end
  end
end

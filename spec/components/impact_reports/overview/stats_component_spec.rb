# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactReports::Overview::StatsComponent, :include_application_helper, type: :component do
  let(:school_group) { create(:school_group) }
  let(:impact_report) { SchoolGroups::ImpactReport.new(school_group) }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:base_params) { { impact_report: impact_report, id: id, classes: classes } }

  let(:html) do
    render_inline(described_class.new(**params))
  end

  context 'with base params' do
    let(:params) { base_params }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_css('#overview-cards') }
    it { expect(html).to have_content('Schools') }
    it { expect(html).to have_content('Users') }
    it { expect(html).to have_content('Pupils') }
    it { expect(html).to have_content('Enrolled schools') }
  end
end

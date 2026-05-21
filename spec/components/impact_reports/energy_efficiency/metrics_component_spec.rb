# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactReports::EnergyEfficiency::MetricsComponent, :include_application_helper, type: :component do
  let(:school_group) { create(:school_group) }
  let(:impact_report) { SchoolGroups::ImpactReport.new(school_group) }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let!(:metrics) { {} }
  let!(:run) do
    create(:impact_report_run, categories: %i[overview energy_efficiency], school_group:, energy_efficiency: metrics)
  end

  let(:base_params) { { run: run, id:, classes: } }

  before do
    render_inline(described_class.new(**params))
  end

  context 'with base params' do
    let(:params) { base_params }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(page).to have_css('#energy-efficiency-cards') }
  end
end

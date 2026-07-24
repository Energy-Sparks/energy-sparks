# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactReports::PotentialSavings::MetricsComponent, :include_application_helper, type: :component do
  let(:school_group) { create(:school_group) }
  let(:impact_report) { SchoolGroups::ImpactReport.new(school_group) }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:params) { { run:, id:, classes: } }

  let!(:run) { create(:impact_report_run, :with_potential_savings_metrics, school_group:) }

  let(:cards) { page.all('#potential-savings-cards .layout-cards-stats-component') }

  context 'with basic render' do
    before do
      render_inline(described_class.new(**params))
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(page).to have_css('#potential-savings-cards') }
  end

  context 'with two potential savings metrics' do
    let(:metric_category) { :potential_savings }
    let!(:run) { create(:impact_report_run, school_group:) }
    let!(:gas) do
      create(:impact_report_metric, run:, metric_category:, metric_type: :insulate_pipes, fuel_type: :gas, value: 4,
                                    number_of_schools: 7)
    end
    let!(:electricity) do
      create(:impact_report_metric, run:, metric_category:, metric_type: :use, fuel_type: :electricity, value: 5,
                                    number_of_schools: 6)
    end

    before do
      render_inline(described_class.new(**params))
    end

    it { expect(cards.first).to have_text('Potential electricity savings') }
    it { expect(cards.first).to have_css('.figure', exact_text: electricity.value) }

    it do
      expect(cards.first).to have_text(
        impact_t('potential_savings.keys.use',
                 count: electricity.number_of_schools, fuel_type: 'electricity')
      )
    end

    it { expect(cards[1]).to have_text('Potential gas savings') }
    it { expect(cards[1]).to have_css('.figure', exact_text: gas.value) }

    it do
      expect(cards[1]).to have_text(
        impact_t('potential_savings.keys.insulate_pipes',
                 count: gas.number_of_schools, fuel_type: 'gas')
      )
    end
  end
end

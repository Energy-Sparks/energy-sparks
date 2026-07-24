# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactReports::EnergyEfficiency::MetricsComponent, :include_application_helper, type: :component do
  let(:school_group) { create(:school_group) }
  let(:cards) { page.all('#energy-efficiency-cards .layout-cards-stats-component') }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:metric_category) { :energy_efficiency }

  let(:params) { { run:, id:, classes: } }

  context 'with base params' do
    let(:run) { create(:impact_report_run, categories: %i[overview energy_efficiency], school_group:) }

    before do
      render_inline(described_class.new(**params))
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(page).to have_css('#energy-efficiency-cards') }
  end

  def card_with_title(title)
    cards.find { |card| card.has_css?('h5.elements-header-component', text: title) }
  end

  context 'with specific metrics' do
    let(:run) do
      create(:impact_report_run, categories: %i[overview], school_group:)
    end

    context 'with annual_saving gbp metric' do
      let!(:metric_type) { :annual_saving }
      let!(:metric) do
        create(:impact_report_metric, run:, metric_category:, metric_type:, fuel_type: :electricity, unit: :gbp)
      end
      let(:card) { card_with_title('Total electricity savings') }

      before do
        render_inline(described_class.new(**params))
      end

      it { expect(card).to have_css('.figure', exact_text: "£#{metric.value}") }

      it {
        expect(card).to have_text(impact_t('energy_efficiency.metric_types.annual_saving.gbp.subtext',
                                           fuel_type: 'electricity', count: metric.number_of_schools))
      }
    end

    context 'with holiday_previous_year metric' do
      let!(:metric_type) { :holiday_previous_year }
      let!(:metric) do
        create(:impact_report_metric, run:, metric_category:, metric_type:, fuel_type: :electricity, unit: :gbp)
      end
      let(:card) { card_with_title('Holiday electricity savings compared to last year') }

      before do
        render_inline(described_class.new(**params))
      end

      it { expect(card).to have_css('.figure', exact_text: "£#{metric.value}") }

      it {
        expect(card).to have_text(impact_t("energy_efficiency.metric_types.#{metric_type}.gbp.subtext",
                                           fuel_type: 'electricity', count: metric.number_of_schools))
      }
    end

    context 'with holiday_previous metric' do
      let!(:metric_type) { :holiday_previous }
      let!(:metric) do
        create(:impact_report_metric, run:, metric_category:, metric_type:, fuel_type: :electricity, unit: :gbp)
      end
      let(:card) { card_with_title('Last holiday electricity savings') }

      before do
        render_inline(described_class.new(**params))
      end

      it { expect(card).to have_css('.figure', exact_text: "£#{metric.value}") }

      it {
        expect(card).to have_text(impact_t("energy_efficiency.metric_types.#{metric_type}.gbp.subtext",
                                           fuel_type: 'electricity', count: metric.number_of_schools))
      }
    end

    context 'with annual_saving co2 metric' do
      let!(:metric_type) { :annual_saving }
      let!(:metric) do
        create(:impact_report_metric, run:, metric_category:, metric_type:, fuel_type: :gas, unit: :co2)
      end
      let(:card) { card_with_title('Reduced carbon emissions from gas') }

      before do
        render_inline(described_class.new(**params))
      end

      it { expect(card).to have_css('.figure', exact_text: "#{metric.value} kg CO2") }

      it {
        expect(card).to have_text(impact_t("energy_efficiency.metric_types.#{metric_type}.co2.subtext.gas",
                                           count: metric.number_of_schools))
      }
    end

    context 'with targets metric' do
      let!(:metric_type) { :targets }
      let!(:metric) do
        create(:impact_report_metric, run:, metric_category:, metric_type:, fuel_type: :gas)
      end
      let(:card) { card_with_title('Gas saving targets') }

      before do
        render_inline(described_class.new(**params))
      end

      it { expect(card).to have_css('.figure', exact_text: metric.value) }

      it {
        expect(card).to have_text(impact_t("energy_efficiency.metric_types.#{metric_type}.subtext",
                                           fuel_type: 'gas', count: metric.number_of_schools))
      }
    end

    context 'with a benchmark metric' do
      let!(:metric_type) { :out_of_hours }
      let!(:metric) do
        create(:impact_report_metric, run:, metric_category:, metric_type:, fuel_type: :gas)
      end
      let(:card) { card_with_title('Reducing out of hours gas use') }

      before do
        render_inline(described_class.new(**params))
      end

      it { expect(card).to have_css('.figure', exact_text: metric.value) }

      it {
        expect(card).to have_text(impact_t("energy_efficiency.metric_types.#{metric_type}.subtext",
                                           fuel_type: 'gas', count: metric.number_of_schools))
      }
    end
  end
end

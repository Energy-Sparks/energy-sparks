# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactReports::Engagement::MetricsComponent, :include_application_helper, type: :component do
  let(:school_group) { create(:school_group) }
  let(:cards) { page.all('#engagement-cards .layout-cards-stats-component') }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:base_params) { { run:, id:, classes: } }
  let(:params) { base_params }

  let(:metrics) { {} }
  let!(:run) { create(:impact_report_run, categories: %i[overview engagement], school_group:, engagement: metrics) }

  before do
    render_inline(described_class.new(**params))
  end

  context 'with base params' do
    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end
  end

  def card_with_title(title)
    cards.find { |card| card.has_css?('h5.elements-header-component', text: title) }
  end

  describe 'activities card' do
    let(:card) { card_with_title('Pupil activities') }

    context 'when activities is nonzero' do
      it { expect(card).to have_css('.figure', exact_text: run.engagement(:activities).value) }

      it do
        expect(card).to have_text(
          impact_t('engagement.cards.activities.subtext',
                   count: run.engagement(:activities).number_of_schools)
        )
      end
    end

    context 'when activities is zero' do
      let(:metrics) { { activities: { value: 0 } } }

      it { expect(card).to be_nil }
    end
  end

  describe 'actions card' do
    let(:card) { card_with_title('Adult actions') }

    context 'when actions is nonzero' do
      it { expect(card).to have_css('.figure', exact_text: run.engagement(:actions).value) }

      it do
        expect(card).to have_text(
          impact_t('engagement.cards.actions.subtext',
                   count: run.overview(:active_users).value)
        )
      end
    end

    context 'when actions is zero' do
      let(:metrics) { { actions: { value: 0 } } }

      it { expect(card).to be_nil }
    end
  end

  describe 'points card' do
    let(:card) { card_with_title('Points') }

    context 'when points is nonzero' do
      it { expect(card).to have_css('.figure', exact_text: run.engagement(:points).value) }
      it { expect(card).to have_text(impact_t('engagement.cards.points.subtext')) }
    end

    context 'when points is zero' do
      let(:metrics) { { points: { value: 0 } } }

      it { expect(card).to be_nil }
    end
  end

  describe 'targets card' do
    let(:card) { card_with_title('Current targets') }

    context 'when targets is nonzero' do
      it { expect(card).to have_css('.figure', exact_text: run.engagement(:targets).value) }
      it { expect(card).to have_text(impact_t('engagement.cards.targets.subtext')) }
    end

    context 'when targets is zero' do
      let(:metrics) { { targets: { value: 0 } } }

      it { expect(card).to be_nil }
    end
  end

  context 'when all metrics do not have enough data' do
    let(:metrics) do
      { activities: { enough_data: false }, actions: { enough_data: false }, points: { enough_data: false },
        targets: { enough_data: false } }
    end

    it { expect(cards.count).to be_zero }
    it { expect(rendered_content).to be_blank }
  end

  context 'when all cards are nonzero' do
    let(:metrics) { { activities: { value: 0 }, actions: { value: 0 }, points: { value: 0 }, targets: { value: 0 } } }

    it { expect(cards.count).to be_zero }
    it { expect(rendered_content).to be_blank }
  end
end

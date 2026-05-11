# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactReports::Engagement::MetricsComponent, :include_application_helper, type: :component do
  let(:school_group) { create(:school_group) }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:base_params) { { run: run, id: id, classes: classes } }
  let!(:run) { create(:impact_report_run, categories: %i[overview engagement], school_group:) }

  before do
    render_inline(described_class.new(**params))
  end

  context 'with base params' do
    let(:params) { base_params }
    let(:cards) { page.all('#engagement-cards .layout-cards-stats-component') }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    describe 'activities card' do
      let(:card) { cards[0] }

      it { expect(card).to have_text('Pupil activities') }
      it { expect(card).to have_css('.figure', exact_text: run.engagement(:activities).value) }

      it do
        expect(card).to have_text(
          impact_t('engagement.cards.activities.subtext',
                   count: run.engagement(:activities).number_of_schools)
        )
      end
    end

    describe 'actions card' do
      let(:card) { cards[1] }

      it { expect(card).to have_text('Adult actions') }
      it { expect(card).to have_css('.figure', exact_text: run.engagement(:actions).value) }

      it do
        expect(card).to have_text(
          impact_t('engagement.cards.actions.subtext',
                   count: run.overview(:active_users).value)
        )
      end
    end

    describe 'points card' do
      let(:card) { cards[2] }

      it { expect(card).to have_text('Points') }
      it { expect(card).to have_css('.figure', exact_text: run.engagement(:points).value) }
      it { expect(card).to have_text(impact_t('engagement.cards.points.subtext')) }
    end

    describe 'tagets card' do
      let(:card) { cards[3] }

      it { expect(card).to have_text('Targets') }
      it { expect(card).to have_css('.figure', exact_text: run.engagement(:targets).value) }
      it { expect(card).to have_text(impact_t('engagement.cards.targets.subtext')) }
    end
  end
end

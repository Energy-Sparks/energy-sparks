# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactReports::Overview::MetricsComponent, :include_application_helper, type: :component do
  let(:school_group) { create(:school_group) }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let!(:run) { create(:impact_report_run, :with_overview_metrics, school_group:) }
  let(:base_params) { { run:, id:, classes: } }

  before do
    render_inline(described_class.new(**params))
  end

  context 'with base params' do
    let(:params) { base_params }
    let(:cards) { page.all('#overview-cards .layout-cards-stats-component') }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    describe 'schools card' do
      let(:card) { cards[0] }

      it { expect(card).to have_text('Schools') }
      it { expect(card).to have_css('.figure', exact_text: run.overview(:visible_schools).value) }

      it do
        expect(card).to have_text(
          impact_t('overview.cards.schools.subtext',
                   count: run.overview(:data_visible_schools).value)
        )
      end
    end

    describe 'Adult users card' do
      let(:card) { cards[1] }

      it { expect(card).to have_text('Adult users') }
      it { expect(card).to have_css('.figure', exact_text: run.overview(:users).value) }

      it do
        expect(card).to have_text(
          impact_t('overview.cards.users.subtext',
                   count: run.overview(:active_users).value)
        )
      end
    end

    describe 'pupils card' do
      let(:card) { cards[2] }

      it { expect(card).to have_text('Pupils') }
      it { expect(card).to have_css('.figure', exact_text: run.overview(:pupils).value) }
      it { expect(card).to have_text(impact_t('overview.cards.pupils.subtext')) }
    end

    describe 'enrollment schools card' do
      let(:card) { cards[3] }
      let(:metrics) { {} }
      let!(:run) { create(:impact_report_run, :with_overview_metrics, school_group:, overview: metrics) }

      context 'when enrolling is non-zero' do
        let(:metrics) { { enrolling_schools: { value: 3 }, enrolled_schools: { value: 0 } } }

        it { expect(cards.count).to be(4) }
        it { expect(card).to have_text('Enrolling schools') }
        it { expect(card).to have_css('.figure', exact_text: run.overview(:enrolling_schools).value) }
        it { expect(card).to have_text(impact_t('overview.cards.enrolling_schools.subtext')) }
      end

      context 'when enrolled is non-zero and enrolling is zero' do
        let(:metrics) { { enrolling_schools: { value: 0 }, enrolled_schools: { value: 3 } } }

        it { expect(cards.count).to be(4) }
        it { expect(card).to have_text('Enrolled schools') }
        it { expect(card).to have_css('.figure', exact_text: run.overview(:enrolled_schools).value) }
        it { expect(card).to have_text(impact_t('overview.cards.enrolled_schools.subtext')) }
      end

      context 'when enrolled is non-zero and enrolling is non-zero' do
        let(:metrics) { { enrolling_schools: { value: 3 }, enrolled_schools: { value: 4 } } }

        it { expect(cards.count).to be(4) }
        it { expect(card).to have_text('Enrolling schools') }
        it { expect(card).to have_css('.figure', exact_text: run.overview(:enrolling_schools).value) }
        it { expect(card).to have_text(impact_t('overview.cards.enrolling_schools.subtext')) }
      end

      context 'when enrolling and enrolled are zero' do
        let(:metrics) { { enrolling_schools: { value: 0 }, enrolled_schools: { value: 0 } } }

        it { expect(cards.count).to be(3) }
      end
    end
  end
end

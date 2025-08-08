# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreboards::ScoreboardSummaryComponent, :include_url_helpers, type: :component do
  let(:scoreboard) { create :scoreboard }
  let(:school) { create :school, scoreboard: scoreboard }
  let(:podium) { Podium.create(school: school, scoreboard: school.scoreboard) }

  let(:params) { { podium: podium } }

  subject(:component) { described_class.new(**params) }

  let(:html) do
    render_inline(component)
  end

  context 'with feature active' do
    before do
      Flipper.enable(:new_dashboards_2024)
    end

    context 'when there is another school on the podium' do
      before { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

      it 'shows scoreboard activity' do
        expect(html).to have_content('Recent activity on your scoreboard')
      end
    end

    context 'when there is only 1 school on the podium' do
      it 'shows energysparks activity' do
        expect(html).to have_content('Recent activity across Energy Sparks')
      end
    end

    context 'when school is not visible' do
      let(:school) { create :school, scoreboard: scoreboard, visible: false }

      context 'when there is another school on the podium' do
        before { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

        it 'shows scoreboard activity' do
          expect(html).to have_content(I18n.t('components.scoreboard_summary.intro'))
        end
      end

      context 'when there is only 1 school on the podium' do
        it 'shows energysparks activity' do
          expect(html).to have_content(I18n.t('components.scoreboard_summary.intro'))
        end
      end
    end
  end

  context 'when there is another school on the podium' do
    before { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

    it 'shows scoreboard activity' do
      expect(html).to have_content('Recent activity on your scoreboard')
    end
  end

  context 'when there is only 1 school on the podium' do
    it 'shows energysparks activity' do
      expect(html).to have_content('Recent activity across Energy Sparks')
    end
  end

  describe '#limit' do
    it { expect(component.limit).to be(4) }
  end

  describe '#school' do
    it { expect(component.school).to eq(school) }
  end

  describe '#scoreboard' do
    it { expect(component.scoreboard).to eq(scoreboard) }
  end

  describe '#other_schools?' do
    it { expect(component.other_schools?).to be(false) }

    context 'when there is another school on the podium' do
      before { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

      it { expect(component.other_schools?).to be(true) }
    end
  end

  describe '#observations' do
    context 'with points' do
      before { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

      it { expect(component.observations).not_to be_empty }
    end

    context 'with no points' do
      before { create :school, :with_points, score_points: 0, scoreboard: scoreboard }

      it { expect(component.observations).to be_empty }
    end
  end
end

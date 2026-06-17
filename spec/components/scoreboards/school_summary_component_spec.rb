# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreboards::SchoolSummaryComponent, :include_url_helpers, type: :component do
  subject(:html) do
    render_inline(described_class.new(**params))
  end

  let(:scoreboard) { create(:scoreboard) }
  let(:school) { create(:school, scoreboard: scoreboard) }
  let(:podium) { Podium.create(school: school, scoreboard: school.scoreboard) }

  let(:params) { { podium: podium } }

  context 'when there is another school on the podium' do
    before { create(:school, :with_points, score_points: 50, scoreboard: scoreboard) }

    it 'shows scoreboard activity' do
      expect(html).to have_text('Recent activity on your scoreboard')
    end
  end

  context 'when there is only 1 school on the podium' do
    it 'shows energysparks activity' do
      expect(html).to have_text('Recent activity across Energy Sparks')
    end
  end

  context 'when school is not visible' do
    let(:school) { create(:school, scoreboard: scoreboard, visible: false) }

    context 'when there is another school on the podium' do
      before { create(:school, :with_points, score_points: 50, scoreboard: scoreboard) }

      it 'shows scoreboard activity' do
        expect(html).to have_text(I18n.t('components.scoreboard_summary.intro'))
      end
    end

    context 'when there is only 1 school on the podium' do
      it 'shows energysparks activity' do
        expect(html).to have_text(I18n.t('components.scoreboard_summary.intro'))
      end
    end
  end
end

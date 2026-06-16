# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreboards::GroupSummaryComponent, :include_url_helpers, type: :component do
  subject(:html) do
    render_inline(described_class.new(**params))
  end

  let(:school_group) { create(:school_group, :with_default_scoreboard, :with_active_schools) }

  let(:params) do
    { school_group: school_group, user: create(:admin) }
  end

  before do
    render_inline(described_class.new(**params))
  end

  context 'when there are no activities in group' do
    it { expect(page).to have_text(I18n.t('components.scoreboards.group_summary.podium.no_points_this_year')) }
    it { expect(page).to have_no_css('.timeline-component') }
  end

  context 'when there are activities' do
    before do
      create(:school, :with_points, score_points: 50, school_group: school_group)
      render_inline(described_class.new(**params))
    end

    it { expect(page).to have_no_text(I18n.t('components.scoreboards.group_summary.podium.no_points_this_year')) }

    it 'shows podium correctly' do
      podium = page.find('.scoreboards-podium-component')
      expect(podium).to have_text('Your highest scoring school holds 1st place nationally')
      expect(podium).to have_link('highest scoring school', href: scores_school_group_advice_path(school_group))
    end

    it 'links to scoreboard' do
      expect(page).to have_link(I18n.t('components.scoreboard_summary.view_scoreboard'),
                                href: scores_school_group_advice_path(school_group))
    end

    it { expect(page).to have_text(I18n.t('components.scoreboards.group_summary.timeline.title')) }
  end
end

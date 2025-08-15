# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreboards::GroupSummaryComponent, :include_url_helpers, type: :component do
  let(:school_group) { create(:school_group, :with_default_scoreboard, :with_active_schools) }

  let(:params) do
    { school_group: school_group, user: create(:admin) }
  end

  subject(:html) do
    render_inline(described_class.new(**params))
  end

  context 'when there are no activities in group' do
    it { expect(html).to have_content(I18n.t('components.scoreboards.group_summary.podium.no_points_this_year'))}
    it { expect(html).not_to have_css('.timeline-component')}
  end

  context 'when there are activities' do
    before do
      create :school, :with_points, score_points: 50, school_group: school_group
    end

    it { expect(html).not_to have_content(I18n.t('components.scoreboards.group_summary.podium.no_points_this_year'))}

    it 'shows podium correctly' do
      within('.scoreboards-podium-component') do
        expect(html).to have_content('Your highest scoring school')
        expect(html).to have_link(href: current_scores_school_group_path(school_group))
      end
    end

    it 'links to scoreboard' do
      expect(html).to have_link(I18n.t('components.scoreboard_summary.view_scoreboard'),
                                href: current_scores_school_group_path(school_group))
    end

    it { expect(html).to have_content(I18n.t('components.scoreboards.group_summary.timeline.title'))}
  end
end

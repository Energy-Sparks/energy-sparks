# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreboards::ScoreboardActivityComponent, :include_url_helpers, type: :component do
  subject(:html) do
    render_inline(described_class.new(**params))
  end

  let!(:other_school) { create :school, scoreboard: create(:scoreboard) }
  let!(:activity_type) { create :activity_type, score: 10 }
  let!(:activity) { create(:activity, school: other_school, activity_type:) }
  let!(:observation) { create(:observation, :activity, activity: activity, school: other_school) }

  let(:params) do
    {
      observations: [observation],
      podium: Podium.create(school: create(:school), scoreboard: other_school.scoreboard),
      id: 'custom-id',
      classes: 'extra-classes',
      show_positions: true
    }
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { 'extra-classes' }
    let(:expected_id) { 'custom-id' }
  end

  it 'displays the observations' do
    expect(html).to have_selector(:table_row, [
                                    '1st',
                                    other_school.name,
                                    '10',
                                    activity.display_name
                                  ])
  end

  it { expect(html).to have_link(activity.display_name, href: school_activity_path(other_school, activity)) }

  context 'when not showing positions' do
    let(:params) do
      {
        observations: [observation],
        podium: Podium.create(school: create(:school), scoreboard: other_school.scoreboard),
        id: 'custom-id',
        classes: 'extra-classes',
        show_positions: false
      }
    end

    it 'displays the observations' do
      expect(html).not_to have_content(I18n.t('common.labels.place'))
      expect(html).to have_selector(:table_row, [
                                      other_school.name,
                                      '10',
                                      activity.display_name
                                    ])
    end
  end
end

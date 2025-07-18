# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScoreboardActivityComponent, :include_url_helpers, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:show_positions) { true }
  let!(:scoreboard) { create :scoreboard }
  let!(:school) { create :school, scoreboard: scoreboard }
  let!(:other_school) { create :school, scoreboard: scoreboard }
  let!(:activity_type) { create :activity_type, score: 10 }
  let!(:activity) { create(:activity, school: other_school, activity_type:) }
  let!(:observation) { create(:observation, :activity, activity: activity, school: other_school) }

  let(:podium) { Podium.create(school: school, scoreboard: scoreboard) }

  let(:params) do
    {
      observations: [observation],
      podium: podium,
      id: id,
      classes: classes,
      show_positions: show_positions
    }
  end

  let(:html) do
    render_inline(component)
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { classes }
    let(:expected_id) { id }
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
    let(:show_positions) { false }

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

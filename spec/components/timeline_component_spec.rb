# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimelineComponent, type: :component, include_url_helpers: true do
  let(:observation) { create(:observation, :activity, points: 10) }
  let(:school) { observation.school }
  let(:observations) { [observation] }
  let(:show_actions) { true }
  let(:show_header) { true }
  let(:classes) { 'my-class' }
  let(:id) { 'my-id' }
  let(:params) do
    {
      observations: observations,
      school: school,
      classes: classes,
      id: id,
      show_actions: show_actions,
      show_header: show_header,
      user: user
    }
  end

  let(:user) { create(:admin) }

  let(:html) do
    render_inline(TimelineComponent.new(**params))
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { classes }
    let(:expected_id) { id }
  end

  context 'with new dashboard feature enabled' do
    before do
      Flipper.enable(:new_dashboards_2024)
    end

    it { expect(html).to have_content(I18n.t('timeline.whats_been_going_on'))}
    it { expect(html).to have_content(I18n.t('schools.dashboards.timeline.intro'))}
    it { expect(html).to have_link(I18n.t('activities.show.all_activities')), href: school_timeline_path(school)}

    it { expect(html).to have_selector(:table_row, [observation.at.to_fs(:es_short), observation.points, observation.activity.display_name])}

    it { expect(html).to have_link(observation.activity.display_name, href: school_activity_path(observation.school, observation.activity)) }
  end
end

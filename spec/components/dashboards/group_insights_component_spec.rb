# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupInsightsComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:html) { render_inline(described_class.new(**params)) }

  let(:school_group) { create(:school_group, :with_active_schools) }
  before do
    # Make sure there are no reminders by default
    create(:school_group_cluster, schools: school_group.schools, school_group:) # cluster exists
  end

  let(:params) do
    {
      id: 'custom-id',
      classes: 'extra-classes',
      school_group: school_group,
      schools: school_group.schools,
      user: create(:admin)
    }
  end

  context 'when there are no alerts or reminders' do
    it { expect(html).not_to have_css('#group-reminders') }
    it { expect(html).not_to have_css('#group-alerts') }
  end

  context 'when there are alerts and reminders' do
    let!(:dashboard_message) { create(:dashboard_message, messageable: school_group) }

    include_context 'with a group dashboard alert' do
      let(:schools) { [school_group.schools.first] }
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { 'extra-classes' }
      let(:expected_id) { 'custom-id' }
    end
  end

  context 'when there are only reminders' do
    let!(:dashboard_message) { create(:dashboard_message, messageable: school_group) }

    it { expect(html).to have_css('#group-reminders') }
    it { expect(html).to have_content(dashboard_message.message) }
    it { expect(html).not_to have_css('#group-alerts') }
  end

  context 'when there are only alerts' do
    include_context 'with a group dashboard alert' do
      let(:schools) { [school_group.schools.first] }
    end

    it { expect(html).not_to have_css('#group-reminders') }

    it {
      expect(html).to have_link(I18n.t('schools.show.view_more_alerts'),
                                   href: alerts_school_group_advice_path(school_group))
    }

    it { expect(html).to have_css('#group-alerts') }
    it { expect(html).to have_css('div.prompt-component.negative') }
  end
end

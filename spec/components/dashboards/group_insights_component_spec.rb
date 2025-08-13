# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupInsightsComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:html) { render_inline(described_class.new(**params)) }

  let(:school_group) { create(:school_group, :with_active_schools) }

  let(:params) do
    {
      id: 'custom-id',
      classes: 'extra-classes',
      school_group: school_group,
      user: create(:admin)
    }
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { 'extra-classes' }
    let(:expected_id) { 'custom-id' }
  end

  it { expect(html).to have_content(I18n.t('components.dashboard_insights.title')) }

  context 'when there are reminders' do
    let!(:dashboard_message) { create(:dashboard_message, messageable: school_group) }

    it { expect(html).to have_css('#group-reminders') }
    it { expect(html).to have_content(dashboard_message.message) }
  end
end

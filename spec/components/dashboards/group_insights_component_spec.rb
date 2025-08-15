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

  context 'when there are alerts' do
    before do
      school = create(:school, school_group: school_group)
      version = create(:alert_type_rating_content_version,
             colour: :positive,
             alert_type_rating: create(:alert_type_rating,
                                       group_dashboard_alert_active: true,
                                       rating_from: 0.0,
                                       rating_to: 4.0))
      create(:alert,
             school: school,
             alert_generation_run: create(:alert_generation_run, school: school),
             alert_type: version.alert_type_rating.alert_type,
             rating: 2.0,
             variables: {
                       one_year_saving_kwh: 1.0,
                       average_one_year_saving_gbp: 2.0,
                       one_year_saving_co2: 3.0,
                       time_of_year_relevance: 5.0
             })
    end

    it { expect(html).to have_css('#group-alerts') }
    it { expect(html).to have_css('div.prompt-component.positive') }
  end
end

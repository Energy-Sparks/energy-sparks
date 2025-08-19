# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupAlertsComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:html) do
    render_inline(described_class.new(**params)) do |c|
      c.with_title { I18n.t('advice_pages.index.alerts.title') }
      c.with_link { ActionController::Base.helpers.link_to('Test', home_page_path) }
    end
  end

  let(:school_group) { create(:school_group, :with_active_schools, count: 2) }
  let(:alert_type) { create(:alert_type) }

  let(:params) do
    {
      id: 'custom-id',
      classes: 'extra-classes',
      school_group: school_group
    }
  end

  let(:content_version) do
    create(:alert_type_rating_content_version,
           colour: :negative,
           alert_type_rating: create(:alert_type_rating,
                                     group_dashboard_alert_active: true,
                                     alert_type: alert_type,
                                     rating_from: 6.0,
                                     rating_to: 10.0))
  end


  context 'when there is invalid data' do
    before do
      school_group.schools.each_with_index do |school, index|
        create(:alert,
               school: school,
               alert_generation_run: create(:alert_generation_run, school: school),
               alert_type: content_version.alert_type_rating.alert_type,
               rating: 6.0,
               variables: {
                     one_year_saving_kwh: index == 0 ? nil : 1.0,
                     average_one_year_saving_gbp: 2.0,
                     one_year_saving_co2: 3.0,
                     time_of_year_relevance: 5.0
               })
      end
    end

    it 'does not display the alert' do
      expect(html).to have_css('div.prompt-component.negative')
    end
  end

  context 'when there are alerts to display' do
    before do
      school_group.schools.each do |school|
        create(:alert,
               school: school,
               alert_generation_run: create(:alert_generation_run, school: school),
               alert_type: content_version.alert_type_rating.alert_type,
               rating: 6.0,
               variables: {
                     one_year_saving_kwh: 1.0,
                     average_one_year_saving_gbp: 2.0,
                     one_year_saving_co2: 3.0,
                     time_of_year_relevance: 5.0
               })
      end
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { 'extra-classes' }
      let(:expected_id) { 'custom-id' }
    end

    it { expect(html).to have_content(I18n.t('advice_pages.index.alerts.title')) }
    it { expect(html).to have_link('Test', href: home_page_path) }

    it 'produces the correct prompt' do
      expect(html).to have_css('div.prompt-component.negative')
      expect(html).to have_content(content_version.group_dashboard_title.to_plain_text)
      within('span.fa-stack') do
        expect(html).to have_css('i.fa-bolt')
      end
    end

    context 'when there are multiple alerts for the same alert type' do
      let(:positive_message) { 'Positive rating' }

      before do
        school = create(:school, school_group: school_group)
        version = create(:alert_type_rating_content_version,
               colour: :positive,
               group_dashboard_title: positive_message,
               alert_type_rating: create(:alert_type_rating,
                                         group_dashboard_alert_active: true,
                                         alert_type: alert_type,
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

      it 'returns the alert with most schools' do
        expect(html).to have_css('div.prompt-component.negative')
        expect(html).to have_content(content_version.group_dashboard_title.to_plain_text)

        expect(html).not_to have_css('div.prompt-component.positive')
        expect(html).not_to have_content(positive_message)
      end
    end

    context 'when there are variables in the content' do
      let(:group_dashboard_title) { 'number: {{number_of_schools}}; schools: {{schools}}; describe_schools: {{describe_schools}}; {{total_one_year_saving_kwh}}, {{total_average_one_year_saving_gbp}}, {{total_one_year_saving_co2}}' }

      let(:content_version) do
        create(:alert_type_rating_content_version,
               group_dashboard_title: group_dashboard_title,
               alert_type_rating: create(:alert_type_rating,
                                         alert_type: alert_type,
                                         group_dashboard_alert_active: true,
                                         rating_from: 6.0,
                                         rating_to: 10.0))
      end

      it 'interpolates correctly' do
        expect(html).to have_content(' number: 2; schools: 2 schools; describe_schools: all schools; 2 kWh, £4, 6 kg CO2')
      end
    end
  end
end

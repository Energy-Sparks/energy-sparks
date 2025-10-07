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
  let(:alert_type) { create(:alert_type, group: :benchmarking) }

  let(:params) do
    {
      id: 'custom-id',
      classes: 'extra-classes',
      school_group: school_group,
      schools: school_group.schools
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


  shared_examples 'it links to advice pages' do
    context 'when the alert has an advice page' do
      context 'when there is no group advice page' do
        it 'does not link' do
          expect(html).not_to have_link(I18n.t('schools.show.find_out_more'))
        end
      end

      context 'when there is non-matching advice page' do
        let(:alert_type) { create(:alert_type, group: :benchmarking, advice_page: create(:advice_page)) }

        it 'does not link' do
          expect(html).not_to have_link(I18n.t('schools.show.find_out_more'))
        end
      end

      context 'when there is a group advice page' do
        let(:advice_page) { create(:advice_page, key: :baseload) }
        let(:alert_type) { create(:alert_type, group: :benchmarking, advice_page:) }

        it 'includes a link' do
          expect(html).to have_link(I18n.t('schools.show.find_out_more'),
                                    href: polymorphic_path([:analysis, school_group, :advice, advice_page.key.to_sym]))
        end
      end
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

    it 'does not include group headings' do
      expect(html).not_to have_css('#benchmarking-alerts')
    end

    it_behaves_like 'it links to advice pages'

    context 'when showing groups' do
      let(:fragment) { html.css('#benchmarking-alerts') }
      let(:params) do
        {
          id: 'custom-id',
          classes: 'extra-classes',
          school_group: school_group,
          schools: school_group.schools,
          grouped: true
        }
      end

      it_behaves_like 'it links to advice pages'

      it 'shows the group headings' do
        expect(fragment).to have_content(content_version.group_dashboard_title.to_plain_text)
        expect(fragment).to have_content(I18n.t('advice_pages.alerts.groups.benchmarking'))
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

      it 'shows the alert with most schools' do
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

    context 'when some schools are not data enabled' do
      before do
        school_group.schools.last.update!(data_enabled: false)
      end

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

      it 'only includes the data enabled schools' do
        expect(html).to have_content(' number: 1; schools: 1 school; describe_schools: all schools; 1 kWh, £2, 3 kg CO2')
      end
    end
  end
end

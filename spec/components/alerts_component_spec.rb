# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlertsComponent, type: :component, include_url_helpers: true do
  let(:school) { create(:school) }
  let(:show_links) { true }
  let(:advice_page) { create(:advice_page, key: :baseload) }
  let(:alert_type) { create(:alert_type, advice_page: advice_page) }
  let(:alert) { create(:alert, alert_type: alert_type) }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }

  let(:alert_content) do
    double(management_dashboard_title: 'adult alert text',
    pupil_dashboard_title: 'pupil alert text',
    colour: :positive,
    alert: alert,
    alert_type: alert_type,
    advice_page: advice_page,
    find_out_more: true)
  end

  let(:dashboard_alerts) { [alert_content] }
  let(:all_params) do
    {
      dashboard_alerts: dashboard_alerts,
      alert_types: [alert_type],
      school: school,
      show_links: show_links,
      id: id,
      classes: classes
    }
  end

  let(:html) { render_inline(AlertsComponent.new(**all_params)) }

  context 'with all params' do
    it 'adds specified classes' do
      expect(html).to have_css('div.alerts-component')
      expect(html).to have_css('div.positive')
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it 'displays alert content' do
      expect(html).to have_content('adult alert text')
    end

    it 'displays links' do
      expect(html).to have_link(I18n.t('schools.show.find_out_more'))
    end

    context 'without links' do
      let(:show_links) { false }

      it 'does not display links' do
        expect(html).not_to have_link(I18n.t('schools.show.find_out_more'))
      end
    end

    it 'displays icons' do
      expect(html).to have_css('i.fa-fire')
    end

    it 'has 11 columns' do
      expect(html).to have_css('div.col-md-11')
    end
  end

  context 'with different audience' do
    let(:all_params) do
      {
        dashboard_alerts: dashboard_alerts,
        school: school,
        audience: :pupil,
        show_links: show_links
      }
    end

    it 'displays alert content' do
      expect(html).not_to have_content('adult alert text')
      expect(html).to have_content('pupil alert text')
    end

    it 'displays links' do
      expect(html).to have_link(I18n.t('schools.show.find_out_more'))
    end
  end

  context 'with no filtering of alert types' do
    let(:all_params) do
      {
        dashboard_alerts: dashboard_alerts,
        school: school,
        show_links: show_links
      }
    end

    it 'displays alert content' do
      expect(html).to have_content('adult alert text')
    end

    it 'displays links' do
      expect(html).to have_link(I18n.t('schools.show.find_out_more'))
    end
  end
end

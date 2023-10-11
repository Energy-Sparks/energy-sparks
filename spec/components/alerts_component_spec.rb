# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlertsComponent, type: :component, include_url_helpers: true do
  let(:school) { create(:school) }
  let(:show_links) { true }
  let(:show_icons) { true }
  let(:advice_page) { create(:advice_page, key: :baseload) }
  let(:alert_type) { create(:alert_type, advice_page: advice_page) }
  let(:alert) { create(:alert, alert_type: alert_type) }
  let(:alert_content) { double(management_dashboard_title: 'some alert text', colour: :positive, alert: alert) }
  let(:dashboard_alerts) { [alert_content] }
  let(:all_params) { { dashboard_alerts: dashboard_alerts, alert_types: [alert_type], school: school, show_links: show_links, show_icons: show_icons } }

  let(:html) { render_inline(AlertsComponent.new(**params)) }

  context 'with all params' do
    let(:params) { all_params }

    it 'adds specified classes' do
      expect(html).to have_css('div.alerts-component')
      expect(html).to have_css('div.positive')
    end

    it 'displays alert content' do
      expect(html).to have_content('some alert text')
    end

    it 'displays links' do
      expect(html).to have_link('View analysis')
    end

    context 'without links' do
      let(:show_links) { false }

      it 'does not display links' do
        expect(html).not_to have_link('View analysis')
      end
    end

    it 'displays icons' do
      expect(html).to have_css('i.fa-fire')
    end

    context 'without icons' do
      let(:show_links) { false }

      it 'does not display icons' do
        expect(html).to have_css('i.fa-fire')
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardChartsComponent, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:id) { 'custom-id'}
  let(:classes) { 'extra-classes' }
  let(:school) { create(:school) }

  let(:params) do
    {
      school: school,
      id: id,
      classes: classes
    }
  end

  shared_context 'with chart configuration' do
    let(:dashboard_charts) do
      [:management_dashboard_group_by_week_electricity,
       :management_dashboard_group_by_week_gas,
       :management_dashboard_group_by_week_storage_heater,
       :management_dashboard_group_by_month_solar_pv]
    end

    before do
      school.configuration.update(dashboard_charts: dashboard_charts)
    end
  end

  describe '#render?' do
    it 'does not render without chart configuration' do
      expect(component.render?).to be(false)
    end

    context 'with chart configuration' do
      include_context 'with chart configuration'

      it { expect(component.render?).to be(true) }
    end
  end

  describe 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    include_context 'with chart configuration'

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it 'renders all the charts' do
      expect(html).to have_css('#management-energy-overview')
      expect(html).to have_css('#electricity-overview')
      expect(html).to have_css('#gas-overview')
      expect(html).to have_css('#storage_heater-overview')
      expect(html).to have_css('#solar-overview')
      dashboard_charts.each do |chart|
        expect(html).to have_css("#chart_wrapper_#{chart}")
      end
    end
  end
end

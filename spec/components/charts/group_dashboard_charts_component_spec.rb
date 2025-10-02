# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Charts::GroupDashboardChartsComponent, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let!(:school_group) { create(:school_group, :with_active_schools, count: 2) }
  let(:comparisons) { [:annual_energy_use] }

  let(:params) do
    {
      id: 'custom-id',
      classes: 'extra-classes',
      school_group: school_group,
      comparisons: comparisons
    }
  end

  before do
    comparisons.each { |c| create(:report, key: c) }
  end

  describe '#render?' do
    context 'without comparisons' do
      let(:comparisons) { [] }

      it 'does not render' do
        expect(component.render?).to be(false)
      end
    end

    context 'without schools' do
      let(:school_group) { create(:school_group) }

      it 'does not render' do
        expect(component.render?).to be(false)
      end
    end

    context 'with only single active school' do
      let!(:school_group) { create(:school_group, :with_active_schools, count: 1) }

      it 'does not render' do
        expect(component.render?).to be(false)
      end
    end

    it 'renders with comparisons and schools' do
      expect(component.render?).to be(true)
    end
  end

  describe 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { 'extra-classes' }
      let(:expected_id) { 'custom-id' }
    end

    it 'renders all the charts' do
      expect(html).to have_css('#management-energy-overview')
      expect(html).to have_css("##{comparisons.first}")
      comparisons.each do |chart|
        expect(html).to have_css("#chart_wrapper_#{chart}")
        expect(html).to have_css("div.#{chart}-analysis-chart")
        expect(html).to have_selector("div.#{chart}-analysis-chart") do |d|
          JSON.parse(d['data-chart-config'])['chart1_subtype'] == 'stacked'
        end
      end

      expect(html).to have_selector('div.annual_energy_use-analysis-chart') do |d|
        url = JSON.parse(d['data-chart-config'])['jsonUrl']
        url == comparisons_annual_energy_use_index_path(params: { school_group_ids: [school_group.id] },
                                                        format: :json)
      end
    end

    it 'includes view analysis link' do
      expect(html).to have_link(I18n.t('school_groups.priority_actions.view_analysis'),
                                href: compare_path(group: true,
                                             benchmark: comparisons.first,
                                             school_group_ids: [school_group.id]))
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupEnergySummaryComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:school_group) { create(:school_group) }
  let!(:school) { create(:school, :with_fuel_configuration, school_group: school_group) }
  let(:html) do
    render_inline(described_class.new(
                    school_group: school_group,
                    schools: school_group.schools,
                    fuel_types: school.configuration.fuel_configuration.fuel_types
    ))
  end

  RSpec.shared_examples 'a group energy summary component' do
    it { expect(html).to have_css('div.dashboards-group-energy-summary-component') }
    it { expect(html).to have_css('#group-energy-overview') }
    it { expect(html).to have_css('#group-energy-overview-tabs') }
    it { expect(html).to have_css('ul.nav-tabs.url-aware') }
    it { expect(html).to have_css('#metric-selection') }

    it 'has download link' do
      expect(html).to have_link(I18n.t('school_groups.download_as_csv'),
                                href: school_group_path(school_group, format: :csv))
    end

    it 'has metric selected' do
      expect(html).to have_checked_field(I18n.t("school_groups.show.metric.#{metric}"))
    end
  end

  context 'with default options' do
    it_behaves_like 'a group energy summary component' do
      let(:metric) { :change }
    end

    it 'has tabs and content for all fuel types' do
      [:electricity, :gas, :storage_heaters].each do |fuel_type|
        expect(html).to have_css("##{fuel_type}-tab")
        expect(html).to have_css("##{fuel_type}-overview")
      end
    end
  end

  context 'with a different metric' do
    let(:html) do
      render_inline(described_class.new(
                      school_group: school_group,
                      schools: school_group.schools,
                      fuel_types: school.configuration.fuel_configuration.fuel_types,
                      metric: :usage
      ))
    end

    it_behaves_like 'a group energy summary component' do
      let(:metric) { :usage }
    end
  end

  context 'with limited fuel types' do
    let!(:school) do
      create(:school,
                           :with_fuel_configuration,
                           has_gas: false,
                           has_storage_heaters: false,
                           school_group: school_group)
    end

    it_behaves_like 'a group energy summary component' do
      let(:metric) { :change }
    end

    it 'has electricity overview' do
      expect(html).to have_css('#electricity-tab')
      expect(html).to have_css('#electricity-overview')
    end

    it 'does not have tabs and content for the other fuel types' do
      [:gas, :storage_heaters].each do |fuel_type|
        expect(html).not_to have_css("##{fuel_type}-tab")
        expect(html).not_to have_css("##{fuel_type}-overview")
      end
    end
  end

  context 'with no schools' do
    let(:school) { create(:school, :with_school_group) }

    it { expect(html).not_to have_css('div.dashboards-group-energy-summary-component') }
  end
end

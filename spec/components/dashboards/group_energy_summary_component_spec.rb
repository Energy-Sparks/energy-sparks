# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupEnergySummaryComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:school_group) { create(:school_group) }
  let!(:school) { create(:school, :with_fuel_configuration, school_group: school_group) }

  before do
    render_inline(described_class.new(
                    school_group: school_group,
                    schools: school_group.schools,
                    fuel_types: school.configuration.fuel_configuration.fuel_types
    ))
  end

  RSpec.shared_examples 'a group energy summary component' do
    it { expect(page).to have_css('div.dashboards-group-energy-summary-component') }
    it { expect(page).to have_css('#group-energy-overview') }
    it { expect(page).to have_css('#group-energy-overview-tabs') }
    it { expect(page).to have_css('ul.nav-tabs.url-aware') }
    it { expect(page).to have_css('#metric-selection') }

    it 'has download link' do
      expect(page).to have_link(I18n.t('school_groups.download_as_csv'),
                                href: school_group_path(school_group, format: :csv))
    end

    it 'has metric selected' do
      expect(page).to have_checked_field(I18n.t("school_groups.show.metric.#{metric}"))
    end
  end

  context 'with default options' do
    it_behaves_like 'a group energy summary component' do
      let(:metric) { :change }
    end

    it 'has tabs and content for all fuel types' do
      [:electricity, :gas, :storage_heaters].each do |fuel_type|
        expect(page).to have_css("##{fuel_type}-tab")
        expect(page).to have_css("##{fuel_type}-overview")
      end
    end
  end

  context 'with a different metric' do
    let(:page) do
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
    let(:school) do
      create(:school, :with_fuel_configuration,
                           has_gas: false,
                           has_storage_heaters: false,
                           school_group: school_group)
    end

    it_behaves_like 'a group energy summary component' do
      let(:metric) { :change }
    end

    it 'has electricity overview' do
      expect(page).to have_css('#electricity-tab')
      expect(page).to have_css('#electricity-overview')
    end

    it 'does not have tabs and content for the other fuel types' do
      [:gas, :storage_heaters].each do |fuel_type|
        expect(page).not_to have_css("##{fuel_type}-tab")
        expect(page).not_to have_css("##{fuel_type}-overview")
      end
    end
  end

  context 'with no schools' do
    let(:school) { create(:school, :with_school_group) }

    it { expect(page).not_to have_css('div.dashboards-group-energy-summary-component') }
  end

  describe 'Footers' do
    let(:status_note) { true }

    before do
      render_inline(described_class.new(
                      school_group: school_group,
                      schools: school_group.schools,
                      fuel_types: school.configuration.fuel_configuration.fuel_types,
                      show_status_note: status_note)) do |c|
        c.with_footer { 'Footer' }
        c.with_modal_link { 'Link tag' }
      end
    end

    it 'renders the footer' do
      expect(page).to have_content('Footer')
    end

    it 'renders the modal link' do
      expect(page).to have_content('Link tag')
    end

    context 'with status note' do
      it 'renders status note' do
        expect(page).to have_link('See a full list of schools and their status')
      end
    end

    context 'without status note' do
      let(:status_note) { false }

      it { expect(page).not_to have_link('See a full list of schools and their status') }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdvicePageListComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:id) { 'custom-id'}
  let(:classes) { 'extra-classes' }
  let(:school) { create(:school, :with_fuel_configuration, has_solar_pv: false, has_gas: false, has_storage_heaters: false) }

  let(:params) do
    {
      school: school,
      id: id,
      classes: classes
    }
  end

  let!(:baseload) { create(:advice_page, key: :baseload) }
  let!(:heating_control) { create(:advice_page, key: :heating_control, fuel_type: 'gas') }
  let!(:solar_pv) { create(:advice_page, key: :solar_pv, fuel_type: 'solar_pv') }
  let!(:storage_heaters) { create(:advice_page, key: :storage_heaters, fuel_type: 'storage_heater') }
  let!(:electricity_meter_breakdown) { create(:advice_page, key: :electricity_meter_breakdown, multiple_meters: true) }

  shared_examples 'a properly rended prompt' do
    let(:expected_summary) { nil }
    it { expect(html).to have_link(I18n.t('schools.show.find_out_more'), href: expected_path) }
    it { expect(html).to have_content(I18n.t("advice_pages.nav.pages.#{expected_page.key}")) }
    it { expect(html).to have_content(I18n.t("advice_pages.index.show.page_summary.#{expected_summary || expected_page.key}")) }
  end

  describe '#render?' do
    context 'when school is not data enabled' do
      let(:school) { create(:school, data_enabled: false) }

      it { expect(component.render?).to be(false)}
    end
  end

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_content(I18n.t('components.advice_page_list.title')) }
    it { expect(html).to have_content(I18n.t('components.advice_page_list.intro')) }

    context 'when school has electricity' do
      let(:school) do
        create(:school, :with_fuel_configuration, has_gas: false, has_solar_pv: false, has_storage_heaters: false)
      end

      it { expect(html).to have_content(I18n.t('advice_pages.nav.sections.electricity')) }

      it_behaves_like 'a properly rended prompt' do
        let(:expected_path) { insights_school_advice_baseload_path(school) }
        let(:expected_page) { baseload }
      end

      it_behaves_like 'a properly rended prompt' do
        let(:expected_path) { insights_school_advice_solar_pv_path(school) }
        let(:expected_summary) { 'solar_pv.no_solar' }
        let(:expected_page) { solar_pv }
      end

      it { expect(html).to have_no_content(I18n.t("advice_pages.nav.pages.#{electricity_meter_breakdown.key}")) }

      context 'with multiple meters' do
        before do
          create_list(:electricity_meter, 2, school: school)
        end

        it { expect(html).to have_content(I18n.t("advice_pages.nav.pages.#{electricity_meter_breakdown.key}")) }
      end
    end

    context 'when school has gas' do
      let(:school) { create(:school, :with_fuel_configuration, has_solar_pv: false, has_storage_heaters: false) }

      it { expect(html).to have_content(I18n.t('advice_pages.nav.sections.gas')) }

      it_behaves_like 'a properly rended prompt' do
        let(:expected_path) { insights_school_advice_heating_control_path(school) }
        let(:expected_page) { heating_control }
      end

      it_behaves_like 'a properly rended prompt' do
        let(:expected_path) { insights_school_advice_solar_pv_path(school) }
        let(:expected_summary) { 'solar_pv.no_solar' }
        let(:expected_page) { solar_pv }
      end
    end

    context 'when school has storage heaters' do
      let(:school) { create(:school, :with_fuel_configuration, has_solar_pv: false, has_gas: false) }

      it { expect(html).to have_content(I18n.t('advice_pages.nav.sections.storage_heater')) }

      it_behaves_like 'a properly rended prompt' do
        let(:expected_path) { insights_school_advice_storage_heaters_path(school) }
        let(:expected_page) { storage_heaters }
      end

      it_behaves_like 'a properly rended prompt' do
        let(:expected_path) { insights_school_advice_solar_pv_path(school) }
        let(:expected_summary) { 'solar_pv.no_solar' }
        let(:expected_page) { solar_pv }
      end
    end

    context 'when school has solar' do
      let(:school) { create(:school, :with_fuel_configuration, has_storage_heaters: false, has_gas: false) }

      it { expect(html).to have_content(I18n.t('advice_pages.nav.sections.solar_pv')) }

      it_behaves_like 'a properly rended prompt' do
        let(:expected_path) { insights_school_advice_baseload_path(school) }
        let(:expected_page) { baseload }
      end

      it_behaves_like 'a properly rended prompt' do
        let(:expected_path) { insights_school_advice_solar_pv_path(school) }
        let(:expected_summary) { 'solar_pv.has_solar' }
        let(:expected_page) { solar_pv }
      end
    end

    context 'when school has a benchmark' do
      let!(:benchmark) { create(:advice_page_school_benchmark, school: school, advice_page: baseload) }

      it { expect(html).to have_content(I18n.t("advice_pages.benchmarks.#{benchmark.benchmarked_as}"))}
    end
  end
end

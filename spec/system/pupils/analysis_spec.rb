require 'rails_helper'

describe 'Pupil analysis' do
  let(:school) { create(:school, :with_fuel_configuration) }

  before do
    Flipper.enable :new_dashboards_2024
  end

  context 'when visiting analysis index' do
    before do
      visit pupils_school_analysis_path(school)
    end

    context 'with all fuel types' do
      it {
        expect(page).to have_link(I18n.t('common.electricity_and_solar_pv'),
                                     href: pupils_school_analysis_path(school, category: :solar_pv))
      }

      it { expect(page).to have_no_link(href: pupils_school_analysis_path(school, category: :electricity)) }
      it { expect(page).to have_link(I18n.t('common.gas'), href: pupils_school_analysis_path(school, category: :gas)) }

      it {
        expect(page).to have_link(I18n.t('common.storage_heaters'),
                                     href: pupils_school_analysis_path(school, category: :storage_heaters))
      }

      it { expect(page).to have_content(I18n.t('pupils.analysis.without_storage_heaters')) }
    end

    context 'with electricity and no solar' do
      let(:school) { create(:school, :with_fuel_configuration, has_solar_pv: false) }

      it {
        expect(page).to have_link(I18n.t('common.electricity'),
                                     href: pupils_school_analysis_path(school, category: :electricity))
      }

      it { expect(page).to have_no_link(href: pupils_school_analysis_path(school, category: :solar_pv)) }
    end

    context 'with only electricity' do
      let(:school) { create(:school, :with_fuel_configuration, has_gas: false, has_solar_pv: false, has_storage_heaters: false) }

      it { expect(page).to have_link(I18n.t('common.electricity'), href: pupils_school_analysis_path(school, category: :electricity)) }

      [:solar_pv, :gas, :storage_heaters].each do |category|
        it { expect(page).to have_no_link(href: pupils_school_analysis_path(school, category: category)) }
      end
      it { expect(page).not_to have_content(I18n.t('pupils.analysis.without_storage_heaters')) }
    end

    context 'with only gas' do
      let(:school) { create(:school, :with_fuel_configuration, has_electricity: false, has_solar_pv: false, has_storage_heaters: false) }

      it { expect(page).to have_link(I18n.t('common.gas'), href: pupils_school_analysis_path(school, category: :gas)) }

      [:solar_pv, :electricity, :storage_heaters].each do |category|
        it { expect(page).to have_no_link(href: pupils_school_analysis_path(school, category: category)) }
      end

      it { expect(page).not_to have_content(I18n.t('pupils.analysis.without_storage_heaters')) }
    end

    context 'with storage heaters' do
      let(:school) { create(:school, :with_fuel_configuration, has_gas: false, has_solar_pv: false) }

      it {
        expect(page).to have_link(I18n.t('common.electricity'),
                                     href: pupils_school_analysis_path(school, category: :electricity))
      }

      it {
        expect(page).to have_link(I18n.t('common.storage_heaters'),
                                     href: pupils_school_analysis_path(school, category: :storage_heaters))
      }

      [:solar_pv, :gas].each do |category|
        it { expect(page).to have_no_link(href: pupils_school_analysis_path(school, category: category)) }
      end

      it { expect(page).to have_content(I18n.t('pupils.analysis.without_storage_heaters')) }
    end
  end

  context 'when viewing electricity category' do
    it 'links to bar charts category'
    it 'links to line charts category'
    it 'links to pie chart'
    it 'links to compare weeks'
    it 'links to compare days'
    it 'has not link for meters'
    context 'with multiple electricity meters' do
      it 'links to compare meters'
    end

    it 'links to kwh chart'
    it 'links to cost chart'
    it 'links to co2 chart'

    context 'when viewing bar charts' do
      it 'links to electricity index'
      it 'links to school comparison'
      it 'links to long term'
      it 'links to last year'
      it 'compares weeks'
      it 'has not link for meters'
      context 'with multiple electricity meters' do
        it 'links to compare meters'
      end
    end

    context 'with viewing line charts' do
      it 'links to electricity index'
      it 'links to last 7 days'
      it 'links to baseload'
      it 'links to compare days'
      it 'has not link for meters'
      context 'with multiple electricity meters' do
        it 'links to compare meters'
      end
    end
  end
end

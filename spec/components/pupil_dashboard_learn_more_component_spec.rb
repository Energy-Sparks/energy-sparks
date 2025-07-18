# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PupilDashboardLearnMoreComponent, :include_url_helpers, type: :component do
  let(:school) { create(:school, :with_fuel_configuration) }

  let(:user) { create(:school_admin, school: school)}
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:params) do
    {
      id: id,
      classes: classes,
      school: school,
      user: user
    }
  end

  let(:html) { render_inline(described_class.new(**params)) }

  it_behaves_like 'an application component' do
    let(:expected_classes) { classes }
    let(:expected_id) { id }
  end

  shared_examples 'a data enabled panel' do
    it { expect(html).to have_css('.data-enabled')}
    it { expect(html).to have_content(I18n.t('components.dashboard_learn_more.pupil.title'))}

    context 'with all fuel types' do
      it {
        expect(html).to have_link(I18n.t('common.electricity_and_solar_pv'),
                                     href: pupils_school_analysis_path(school, category: :solar_pv))
      }

      it { expect(html).to have_no_link(href: pupils_school_analysis_path(school, category: :electricity)) }
      it { expect(html).to have_link(I18n.t('common.gas'), href: pupils_school_analysis_path(school, category: :gas)) }

      it {
        expect(html).to have_link(I18n.t('common.storage_heaters'),
                                     href: pupils_school_analysis_path(school, category: :storage_heaters))
      }

      it { expect(html).to have_content(I18n.t('pupils.analysis.without_storage_heaters')) }
    end

    context 'with electricity and no solar' do
      let(:school) { create(:school, :with_fuel_configuration, has_solar_pv: false) }

      it {
        expect(html).to have_link(I18n.t('common.electricity'),
                                     href: pupils_school_analysis_path(school, category: :electricity))
      }

      it { expect(html).to have_no_link(href: pupils_school_analysis_path(school, category: :solar_pv)) }
    end

    context 'with only electricity' do
      let(:school) { create(:school, :with_fuel_configuration, has_gas: false, has_solar_pv: false, has_storage_heaters: false) }

      it { expect(html).to have_link(I18n.t('common.electricity'), href: pupils_school_analysis_path(school, category: :electricity)) }

      [:solar_pv, :gas, :storage_heaters].each do |category|
        it { expect(html).to have_no_link(href: pupils_school_analysis_path(school, category: category)) }
      end
      it { expect(html).not_to have_content(I18n.t('pupils.analysis.without_storage_heaters')) }
    end

    context 'with only gas' do
      let(:school) { create(:school, :with_fuel_configuration, has_electricity: false, has_solar_pv: false, has_storage_heaters: false) }

      it { expect(html).to have_link(I18n.t('common.gas'), href: pupils_school_analysis_path(school, category: :gas)) }

      [:solar_pv, :electricity, :storage_heaters].each do |category|
        it { expect(html).to have_no_link(href: pupils_school_analysis_path(school, category: category)) }
      end

      it { expect(html).not_to have_content(I18n.t('pupils.analysis.without_storage_heaters')) }
    end

    context 'with storage heaters' do
      let(:school) { create(:school, :with_fuel_configuration, has_gas: false, has_solar_pv: false) }

      it {
        expect(html).to have_link(I18n.t('common.electricity'),
                                     href: pupils_school_analysis_path(school, category: :electricity))
      }

      it {
        expect(html).to have_link(I18n.t('common.storage_heaters'),
                                     href: pupils_school_analysis_path(school, category: :storage_heaters))
      }

      [:solar_pv, :gas].each do |category|
        it { expect(html).to have_no_link(href: pupils_school_analysis_path(school, category: category)) }
      end

      it { expect(html).to have_content(I18n.t('pupils.analysis.without_storage_heaters')) }
    end
  end

  context 'when school is not data enabled' do
    let(:school) { create(:school, :with_fuel_configuration, data_enabled: false) }

    it { expect(html).to have_css('.data-disabled')}
    it { expect(html).to have_content(I18n.t('schools.show.coming_soon'))}
    it { expect(html).to have_content(I18n.t('pupils.schools.show.setting_up'))}

    context 'with admin' do
      let(:user) { create(:admin) }

      it_behaves_like 'a data enabled panel'
    end
  end

  context 'when school is data enabled' do
    it_behaves_like 'a data enabled panel'
  end
end

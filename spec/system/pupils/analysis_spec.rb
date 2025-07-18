require 'rails_helper'

describe 'Pupil analysis' do
  let(:school) { create(:school, :with_fuel_configuration) }

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

  def expect_chart_link(school, label, *args)
    expect(page).to have_link(label, href: pupils_school_analysis_tab_path(school, *args))
  end

  def expect_usage_chart_link(school, label, **args)
    expect(page).to have_link(label, href: school_usage_path(school, **args))
  end

  shared_examples 'it has the right headings and navigation' do |fuel_type:|
    it { expect(page).to have_title(I18n.t('pupils.analysis.explore_energy_data_html', fuel_type: I18n.t("common.#{fuel_type}").downcase))}
    it { expect(page).to have_content(I18n.t('pupils.analysis.explore_energy_data_html', fuel_type: I18n.t("common.#{fuel_type}").downcase))}

    it {
      expect(page).to have_link(I18n.t('pupils.analysis.explore_all', fuel_type: I18n.t("common.#{fuel_type}").downcase),
                                   href: pupils_school_analysis_path(school, category: fuel_type))
    }
  end

  shared_examples 'it has a top-level how section' do |energy:|
    it { expect_chart_link(school, I18n.t('pupils.analysis.when'), energy, 'kWh') }
    it { expect_chart_link(school, I18n.t('pupils.analysis.how_much'), energy, 'Cost') }
    it { expect_chart_link(school, I18n.t('pupils.analysis.how_much_co2'), energy, 'CO2') }
  end

  shared_examples 'it has a top-level compare section' do |fuel_type:|
    it { expect_usage_chart_link(school, I18n.t('pupils.analysis.compare_different_weeks'), period: :weekly, supply: fuel_type) }
    it { expect_usage_chart_link(school, I18n.t('pupils.analysis.compare_different_days'), period: :daily, supply: fuel_type) }
    it { expect(page).to have_no_link(I18n.t('pupils.analysis.compare_meters'), href: school_usage_path(school, period: :weekly, supply: fuel_type, split_meters: true)) }

    context 'with multiple meters and no storage heaters' do
      let(:school) { create(:school, :with_fuel_configuration, has_storage_heaters: false) }

      before do
        create_list(:"#{fuel_type}_meter", 2, active: true, school: school)
        visit pupils_school_analysis_path(school, category: fuel_type)
      end

      it { expect_usage_chart_link(school, I18n.t('pupils.analysis.compare_meters'), period: :weekly, supply: fuel_type, split_meters: true) }
    end
  end

  shared_examples 'it has a top-level see section' do |energy:, fuel_type:|
    it { expect_chart_link(school, I18n.t('common.pie_charts'), energy, 'Pie') }

    it {
      expect(page).to have_link(I18n.t('common.bar_charts'),
                                href: pupils_school_analysis_path(school, category: :"#{fuel_type}_bar"))
    }

    it {
      expect(page).to have_link(I18n.t('common.line_graphs'),
                                href: pupils_school_analysis_path(school, category: :"#{fuel_type}_line"))
    }
  end

  shared_examples 'a bar charts category' do |energy:, fuel_type:|
    it { expect_chart_link(school, I18n.t('pupils.analysis.how_much_last_year'), energy, 'Bar', 'Week')}
    it { expect_chart_link(school, I18n.t('pupils.analysis.how_changed_long_term'), energy, 'Bar', 'Year')}
    it { expect_chart_link(school, I18n.t('pupils.analysis.compare_electricity_across_schools'), energy, 'Bar', 'Bench')}
    it { expect_usage_chart_link(school, I18n.t('pupils.analysis.compare_different_weeks'), period: :weekly, supply: fuel_type) }

    it {
      expect(page).to have_no_link(I18n.t('pupils.analysis.compare_meters'),
                                      href: school_usage_path(school, period: :weekly, supply: fuel_type, split_meters: true))
    }

    context 'with multiple electricity meters and no storage heaters' do
      let(:school) { create(:school, :with_fuel_configuration, has_storage_heaters: false) }

      before do
        create_list(:"#{fuel_type}_meter", 2, active: true, school: school)
        refresh
      end

      it { expect_usage_chart_link(school, I18n.t('pupils.analysis.compare_meters'), period: :weekly, supply: fuel_type, split_meters: true) }
    end
  end

  shared_examples 'a line charts category' do |energy:, fuel_type:|
    it { expect_chart_link(school, I18n.t('pupils.analysis.how_much_last_week'), energy, 'Line', '7days')}
    it { expect_chart_link(school, I18n.t('pupils.analysis.how_much_baseload'), energy, 'Line', 'Base')}
    it { expect_usage_chart_link(school, I18n.t('pupils.analysis.compare_different_days'), period: :daily, supply: fuel_type) }

    it {
      expect(page).to have_no_link(I18n.t('pupils.analysis.compare_meters'),
                                      href: school_usage_path(school, period: :daily, supply: fuel_type, split_meters: true))
    }

    context 'with multiple electricity meters and no storage heaters' do
      let(:school) { create(:school, :with_fuel_configuration, has_storage_heaters: false) }

      before do
        create_list(:"#{fuel_type}_meter", 2, active: true, school: school)
        refresh
      end

      it { expect_usage_chart_link(school, I18n.t('pupils.analysis.compare_meters'), period: :daily, supply: fuel_type, split_meters: true) }
    end
  end

  context 'when viewing electricity category' do
    before do
      visit pupils_school_analysis_path(school, category: :electricity)
    end

    it_behaves_like 'it has a top-level how section', energy: 'Electricity'
    it_behaves_like 'it has a top-level compare section', fuel_type: :electricity
    it_behaves_like 'it has a top-level see section', energy: 'Electricity', fuel_type: :electricity

    context 'when viewing bar charts' do
      before do
        click_on I18n.t('common.bar_charts')
      end

      it_behaves_like 'it has the right headings and navigation', fuel_type: :electricity
      it_behaves_like 'a bar charts category', energy: 'Electricity', fuel_type: :electricity
    end

    context 'with viewing line charts' do
      before do
        click_on I18n.t('common.line_graphs')
      end

      it_behaves_like 'it has the right headings and navigation', fuel_type: :electricity
      it_behaves_like 'a line charts category', energy: 'Electricity', fuel_type: :electricity
    end
  end

  context 'when viewing gas category' do
    before do
      visit pupils_school_analysis_path(school, category: :gas)
    end

    it_behaves_like 'it has a top-level how section', energy: 'Gas'
    it_behaves_like 'it has a top-level compare section', fuel_type: :gas
    it_behaves_like 'it has a top-level see section', energy: 'Gas', fuel_type: :gas

    context 'when viewing bar charts' do
      before do
        click_on I18n.t('common.bar_charts')
      end

      it_behaves_like 'it has the right headings and navigation', fuel_type: :gas
      it_behaves_like 'a bar charts category', energy: 'Gas', fuel_type: :gas
    end

    context 'when viewing line charts' do
      before do
        click_on I18n.t('common.line_graphs')
      end

      it { expect_chart_link(school, I18n.t('pupils.analysis.how_much_last_week'), 'Gas', 'Line') }

      it { expect_usage_chart_link(school, I18n.t('pupils.analysis.compare_different_days'), period: :daily, supply: :gas) }

      it {
        expect(page).to have_no_link(I18n.t('pupils.analysis.compare_meters'),
                                        href: school_usage_path(school, period: :daily, supply: :gas, split_meters: true))
      }

      context 'with multiple electricity meters and no storage heaters' do
        let(:school) { create(:school, :with_fuel_configuration, has_storage_heaters: false) }

        before do
          create_list(:gas_meter, 2, active: true, school: school)
          refresh
        end

        it { expect_usage_chart_link(school, I18n.t('pupils.analysis.compare_meters'), period: :daily, supply: :gas, split_meters: true) }
      end
    end
  end

  context 'when viewing solar_pv category' do
    before do
      visit pupils_school_analysis_path(school, category: :solar_pv)
    end

    it { expect_chart_link(school, I18n.t('pupils.analysis.when'), 'Electricity', 'kWh') }
    it { expect_chart_link(school, I18n.t('pupils.analysis.how_much_solar'), 'Electricity+Solar PV', 'Solar') }

    it_behaves_like 'it has a top-level compare section', fuel_type: :electricity
    it_behaves_like 'it has a top-level see section', energy: 'Electricity', fuel_type: :solar

    context 'when viewing bar charts' do
      before do
        click_on I18n.t('common.bar_charts')
      end

      it_behaves_like 'a bar charts category', energy: 'Electricity', fuel_type: :electricity

      it {
        expect(page).to have_title(I18n.t('pupils.analysis.explore_energy_data_html',
                                      fuel_type: I18n.t('common.electricity_and_solar_pv').downcase))
      }

      it {
        expect(page).to have_content(I18n.t('pupils.analysis.explore_energy_data_html',
                                        fuel_type: I18n.t('common.electricity_and_solar_pv').downcase))
      }

      it {
        expect(page).to have_link(I18n.t('pupils.analysis.explore_all', fuel_type: I18n.t('common.electricity_and_solar_pv').downcase),
                                     href: pupils_school_analysis_path(school, category: :solar_pv))
      }
    end

    context 'when viewing line charts' do
      before do
        click_on I18n.t('common.line_graphs')
      end

      it_behaves_like 'a line charts category', energy: 'Electricity', fuel_type: :electricity

      it {
        expect(page).to have_title(I18n.t('pupils.analysis.explore_energy_data_html',
                                           fuel_type: I18n.t('common.electricity_and_solar_pv').downcase))
      }

      it {
        expect(page).to have_content(I18n.t('pupils.analysis.explore_energy_data_html',
                                        fuel_type: I18n.t('common.electricity_and_solar_pv').downcase))
      }

      it {
        expect(page).to have_link(I18n.t('pupils.analysis.explore_all', fuel_type: I18n.t('common.electricity_and_solar_pv').downcase),
                                     href: pupils_school_analysis_path(school, category: :solar_pv))
      }
    end
  end

  context 'when viewing storage heaters category' do
    before do
      visit pupils_school_analysis_path(school, category: :storage_heaters)
    end

    it { expect_chart_link(school, I18n.t('common.pie_charts'), 'Storage Heaters', 'Pie') }

    context 'when viewing bar charts' do
      before do
        click_on I18n.t('common.bar_charts')
      end

      it {
        expect(page).to have_title(I18n.t('pupils.analysis.explore_energy_data_html',
                                      fuel_type: I18n.t('common.storage_heater').downcase))
      }

      it {
        expect(page).to have_content(I18n.t('pupils.analysis.explore_energy_data_html',
                                        fuel_type: I18n.t('common.storage_heater').downcase))
      }

      it {
        expect(page).to have_link(I18n.t('pupils.analysis.explore_all', fuel_type: I18n.t('common.storage_heater').downcase),
                                     href: pupils_school_analysis_path(school, category: :storage_heaters))
      }
    end

    it { expect_chart_link(school, I18n.t('common.line_graphs'), 'Storage Heaters', 'Line') }
  end
end

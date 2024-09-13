require 'rails_helper'

describe 'Pupil analysis public displays' do
  let!(:school) { create(:school, :with_fuel_configuration) }

  before do
    school.configuration.update(aggregate_meter_dates: {
      electricity: { start_date: Time.zone.yesterday, end_date: Time.zone.today },
      gas: { start_date: Time.zone.yesterday, end_date: Time.zone.today },
    })
  end

  context 'when viewing index' do
    before do
      visit pupils_school_public_displays_path(school)
    end

    it 'displays title' do
      expect(page).to have_title(I18n.t('pupils.public_displays.index.title'))
      expect(page).to have_content(I18n.t('pupils.public_displays.index.title'))
    end

    fuel_types = %i[electricity gas]
    chart_types = %i[out_of_hours last_week]

    fuel_types.each do |fuel_type|
      it { expect(page).to have_link(href: pupils_school_public_displays_equivalences_path(school, fuel_type))}

      chart_types.each do |chart_type|
        it { expect(page).to have_link(href: pupils_school_public_displays_charts_path(school, fuel_type, chart_type))}
      end
    end
  end

  context 'when viewing charts' do
    shared_examples 'a working chart page' do
      it 'includes the chart' do
        expect(page).to have_css("#chart_#{expected_chart}")
      end

      it 'shows the title and intro' do
        expect(page).to have_content(I18n.t("pupils.public_displays.charts.#{chart_type}.title",
                                            fuel_type: I18n.t("common.#{fuel_type}").downcase))
        expect(page).to have_content(I18n.t("pupils.public_displays.charts.#{chart_type}.intro"))
      end

      it 'shows the date ranges' do
        expect(page).to have_content('Showing energy used')
      end
    end

    context 'when school is data enabled' do
      let!(:school) { create(:school, :with_fuel_configuration) }

      before do
        visit pupils_school_public_displays_charts_path(school, fuel_type, chart_type)
      end

      context 'with electricity' do
        let(:fuel_type) { :electricity }

        context 'with out of hours chart' do
          let(:chart_type) { :out_of_hours }

          it_behaves_like 'a working chart page' do
            let(:expected_chart) { :pupil_dashboard_daytype_breakdown_electricity }
          end
        end

        context 'with last week chart' do
          let(:chart_type) { :last_week }

          it_behaves_like 'a working chart page' do
            let(:expected_chart) { :public_displays_electricity_weekly_comparison }
          end
        end
      end

      context 'with gas' do
        let(:fuel_type) { :gas }

        context 'with out of hours chart' do
          let(:chart_type) { :out_of_hours }

          it_behaves_like 'a working chart page' do
            let(:expected_chart) { :pupil_dashboard_daytype_breakdown_gas }
          end
        end

        context 'with last week chart' do
          let(:chart_type) { :last_week }

          it_behaves_like 'a working chart page' do
            let(:expected_chart) { :public_displays_gas_weekly_comparison }
          end
        end
      end
    end

    context 'when school does not have fuel type' do
      let!(:school) { create(:school, :with_fuel_configuration, has_gas: false) }
      let(:fuel_type) { :gas }
      let(:chart_type) { :out_of_hours }

      context 'when in production' do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
          visit pupils_school_public_displays_charts_path(school, :gas, :out_of_hours)
        end

        it 'shows an error message' do
          expect(page).to have_content(I18n.t('chart_data_values.standard_error_message'))
        end
      end
    end

    context 'when school is not data enabled' do
      let!(:school) { create(:school, :with_fuel_configuration, data_enabled: false) }

      context 'when in production' do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
          visit pupils_school_public_displays_charts_path(school, :electricity, :out_of_hours)
        end

        it 'shows an error message' do
          expect(page).to have_content(I18n.t('chart_data_values.standard_error_message'))
        end
      end
    end

    context 'when school is not public' do
      let!(:school) { create(:school, data_sharing: :within_group) }

      context 'when in production' do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
          visit pupils_school_public_displays_charts_path(school, :gas, :out_of_hours)
        end

        it 'shows an error message' do
          expect(page).to have_content(I18n.t('chart_data_values.standard_error_message'))
        end
      end
    end
  end

  context 'when viewing equivalences' do
    context 'when school is data enabled' do
      let(:equivalence_type)          { create(:equivalence_type, time_period: :last_week, meter_type: :electricity)}
      let(:equivalence_type_content)  { create(:equivalence_type_content_version, equivalence_type: equivalence_type, equivalence_en: 'Your school spent {{gbp}} on electricity last year!', equivalence_cy: 'Gwariodd eich ysgol {{gbp}} ar drydan y llynedd!')}
      let!(:equivalence)              { create(:equivalence, school: school, content_version: equivalence_type_content, data: { 'gbp' => { 'formatted_equivalence' => '£2.00' } }, data_cy: { 'gbp' => { 'formatted_equivalence' => '£9.00' } }, to_date: Time.zone.today) }

      before do
        visit pupils_school_public_displays_equivalences_path(school, :electricity)
      end

      it 'shows equivalences' do
        expect(page).to have_content('Your school spent £2.00 on electricity last year!')
      end

      it 'shows Welsh equivalences' do
        visit pupils_school_public_displays_equivalences_path(school, :electricity, locale: 'cy')
        expect(page).to have_content('Gwariodd eich ysgol £9.00 ar drydan y llynedd')
      end
    end

    context 'when there are no equivalences for the fuel type' do
      before do
        visit pupils_school_public_displays_equivalences_path(school, :gas)
      end

      it 'displays a default equivalence' do
        expect(page).to have_content('the average school')
      end
    end

    context 'when school is not data enabled' do
      let!(:school) { create(:school, data_enabled: false) }

      before do
        visit pupils_school_public_displays_equivalences_path(school, :electricity)
      end

      it 'displays a default equivalence' do
        expect(page).to have_content('the average school')
      end
    end

    context 'when school is not public' do
      let!(:school) { create(:school, data_sharing: :within_group) }

      before do
        visit pupils_school_public_displays_equivalences_path(school, :electricity)
      end

      it 'displays a default equivalence' do
        expect(page).to have_content('the average school')
      end
    end
  end
end

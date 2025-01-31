require 'rails_helper'

describe 'Digital signage pages' do
  let!(:school) { create(:school, :with_fuel_configuration) }

  before do
    school.configuration.update(aggregate_meter_dates: {
      electricity: { start_date: Time.zone.yesterday, end_date: Time.zone.today },
      gas: { start_date: Time.zone.yesterday, end_date: Time.zone.today },
    })
  end

  shared_examples 'it has some basic branding' do
    it 'shows the logo' do
      expect(page).to have_css('.public-display-logo')
    end
  end

  context 'when viewing index' do
    context 'when not signed in' do
      before do
        visit school_digital_signage_path(school)
      end

      it { expect(page).to have_content('You need to sign in or sign up before continuing') }
    end

    context 'when signed in' do
      before do
        sign_in(create(:school_admin, school: school))
        visit school_digital_signage_path(school)
      end

      it 'displays title' do
        expect(page).to have_title(I18n.t('pupils.digital_signage.index.title'))
        expect(page).to have_content(I18n.t('pupils.digital_signage.index.title'))
      end

      fuel_types = %i[electricity gas]

      fuel_types.each do |fuel_type|
        it { expect(page).to have_link(href: pupils_school_digital_signage_equivalences_path(school, fuel_type))}

        Pupils::DigitalSignageController::CHART_TYPES.each do |chart_type|
          it { expect(page).to have_link(href: pupils_school_digital_signage_charts_path(school, fuel_type, chart_type))}
        end
      end

      context 'when school does not have public data' do
        let!(:school) { create(:school, :with_fuel_configuration, data_sharing: :within_group) }

        it 'displays title' do
          expect(page).to have_title(I18n.t('pupils.digital_signage.index.title'))
          expect(page).to have_content(I18n.t('pupils.digital_signage.index.title'))
        end

        fuel_types.each do |fuel_type|
          it { expect(page).not_to have_link(href: pupils_school_digital_signage_equivalences_path(school, fuel_type))}

          Pupils::DigitalSignageController::CHART_TYPES.each do |chart_type|
            it { expect(page).not_to have_link(href: pupils_school_digital_signage_charts_path(school, fuel_type, chart_type))}
          end
        end

        it 'displays a custom message' do
          expect(page).to have_content('Our digital signage feature is currently only available to schools that are publicly sharing their analysis')
        end
      end
    end
  end

  context 'when viewing charts' do
    shared_examples 'a working chart page' do
      it 'includes the chart' do
        expect(page).to have_css("#chart_#{expected_chart}")
      end

      it 'shows the title and intro' do
        expect(page).to have_content(I18n.t("pupils.digital_signage.charts.#{chart_type}.title",
                                            fuel_type: I18n.t("common.#{fuel_type}").downcase))
        expect(page).to have_content(I18n.t("pupils.digital_signage.charts.#{chart_type}.intro"))
      end

      it 'shows the date ranges' do
        expect(page).to have_content('Showing energy used')
      end

      it_behaves_like 'it has some basic branding'
    end

    context 'when school is data enabled' do
      let!(:school) { create(:school, :with_fuel_configuration) }

      before do
        visit pupils_school_digital_signage_charts_path(school, fuel_type, chart_type)
      end

      context 'with electricity' do
        let(:fuel_type) { :electricity }

        context 'with out of hours chart' do
          let(:chart_type) { 'out-of-hours' }

          it_behaves_like 'a working chart page' do
            let(:expected_chart) { :daytype_breakdown_electricity_tolerant }
          end
        end

        context 'with last week chart' do
          let(:chart_type) { 'last-week' }

          it_behaves_like 'a working chart page' do
            let(:expected_chart) { :public_displays_electricity_weekly_comparison }
          end
        end
      end

      context 'with gas' do
        let(:fuel_type) { :gas }

        context 'with out of hours chart' do
          let(:chart_type) { 'out-of-hours' }

          it_behaves_like 'a working chart page' do
            let(:expected_chart) { :daytype_breakdown_gas_tolerant }
          end
        end

        context 'with last week chart' do
          let(:chart_type) { 'last-week' }

          it_behaves_like 'a working chart page' do
            let(:expected_chart) { :public_displays_gas_weekly_comparison }
          end
        end
      end
    end

    context 'when school does not have fuel type' do
      let!(:school) { create(:school, :with_fuel_configuration, has_gas: false) }

      context 'when in production' do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
          visit pupils_school_digital_signage_charts_path(school, :gas, 'out-of-hours')
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
          visit pupils_school_digital_signage_charts_path(school, :electricity, 'out-of-hours')
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
          visit pupils_school_digital_signage_charts_path(school, :gas, 'out-of-hours')
        end

        it 'shows an error message' do
          expect(page).to have_content(I18n.t('chart_data_values.standard_error_message'))
        end
      end
    end

    context 'when data is out of date' do
      let!(:school) { create(:school, :with_fuel_configuration) }

      context 'with electricity' do
        let(:fuel_type) { :electricity }

        before do
          school.configuration.update(aggregate_meter_dates: {
            electricity: { start_date: Time.zone.today - 90.days, end_date: Time.zone.today - 31.days },
            gas: { start_date: Time.zone.yesterday, end_date: Time.zone.today },
          })
          visit pupils_school_digital_signage_charts_path(school, fuel_type, chart_type)
        end

        context 'with out of hours chart' do
          let(:chart_type) { 'out-of-hours' }

          it_behaves_like 'a working chart page' do
            let(:expected_chart) { :daytype_breakdown_electricity_tolerant }
          end
        end

        context 'with last week chart' do
          let(:chart_type) { 'last-week' }

          it 'redirects to equivalences' do
            expect(page).to have_current_path pupils_school_digital_signage_equivalences_path(school, fuel_type), ignore_query: true
          end
        end
      end

      context 'with gas' do
        let(:fuel_type) { :gas }

        before do
          school.configuration.update(aggregate_meter_dates: {
            electricity: { start_date: Time.zone.yesterday, end_date: Time.zone.today },
            gas: { start_date: Time.zone.today - 90.days, end_date: Time.zone.today - 31.days },
          })
          visit pupils_school_digital_signage_charts_path(school, fuel_type, chart_type)
        end

        context 'with out of hours chart' do
          let(:chart_type) { 'out-of-hours' }

          it_behaves_like 'a working chart page' do
            let(:expected_chart) { :daytype_breakdown_gas_tolerant }
          end
        end

        context 'with last week chart' do
          let(:chart_type) { 'last-week' }

          it 'redirects to equivalences' do
            expect(page).to have_current_path pupils_school_digital_signage_equivalences_path(school, fuel_type), ignore_query: true
          end
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
        visit pupils_school_digital_signage_equivalences_path(school, :electricity)
      end

      it 'shows equivalences' do
        expect(page).to have_content('Your school spent £2.00 on electricity last year!')
      end

      it 'shows Welsh equivalences' do
        visit pupils_school_digital_signage_equivalences_path(school, :electricity, locale: 'cy')
        expect(page).to have_content('Gwariodd eich ysgol £9.00 ar drydan y llynedd')
      end

      it_behaves_like 'it has some basic branding'
    end

    context 'when there are no equivalences for the fuel type' do
      before do
        visit pupils_school_digital_signage_equivalences_path(school, :gas)
      end

      it 'displays a default equivalence' do
        expect(page).to have_content('the average school')
      end

      it_behaves_like 'it has some basic branding'
    end

    context 'when school is not data enabled' do
      let!(:school) { create(:school, data_enabled: false) }

      before do
        visit pupils_school_digital_signage_equivalences_path(school, :electricity)
      end

      it 'displays a default equivalence' do
        expect(page).to have_content('the average school')
      end

      it_behaves_like 'it has some basic branding'
    end

    context 'when school is not public' do
      let!(:school) { create(:school, data_sharing: :within_group) }

      before do
        visit pupils_school_digital_signage_equivalences_path(school, :electricity)
      end

      it 'displays a default equivalence' do
        expect(page).to have_content('the average school')
      end
    end
  end
end

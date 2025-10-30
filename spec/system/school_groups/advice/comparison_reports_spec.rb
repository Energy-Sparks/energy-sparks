require 'rails_helper'

describe 'School group comparison' do
  shared_examples 'a group comparison report index and page' do
    it_behaves_like 'a school group advice page' do
      let(:breadcrumb) { I18n.t('school_groups.titles.comparisons') }
      let(:title) { I18n.t('school_groups.advice.comparison_reports.title', name: school_group.name) }
    end

    it { expect(page).to have_content(I18n.t('school_groups.advice.comparison_reports.lists.long_term')) }
    it { expect(page).to have_content(I18n.t('school_groups.advice.comparison_reports.lists.out_of_hours')) }
    it { expect(page).to have_content(I18n.t('school_groups.advice.comparison_reports.lists.baseload')) }
    it { expect(page).to have_content(I18n.t('school_groups.advice.comparison_reports.lists.heating')) }
    it { expect(page).to have_content(I18n.t('school_groups.advice.comparison_reports.lists.total')) }
    it { expect(page).to have_content(I18n.t('school_groups.advice.comparison_reports.lists.solar')) }

    context 'when clicking through to a comparison' do
      let!(:alerts) do
        alert_run = create(:alert_generation_run, school: school)
        create(:alert, school: school, alert_generation_run: alert_run,
                       alert_type: create(:alert_type, class_name: 'AlertSeasonalBaseloadVariation'),
                       variables: {
                         percent_seasonal_variation: 1,
                         summer_kw: 2,
                         winter_kw: 3,
                         annual_cost_gbpcurrent: 4
                       })
        create(:alert, school: school, alert_generation_run: alert_run,
                       alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                       variables: { electricity_economic_tariff_changed_this_year: true })

        click_on('Seasonal')
      end

      include_context 'with comparison report footnotes' do
        let(:footnotes) { [tariff_changed_last_year] }
      end

      context 'when rendering the page it uses the advice page layout' do
        it 'has the expected navigation' do
          expect(page).to have_css('#group-advice-page-nav')
          within('#group-advice-page-nav') do
            expect(page).to have_link(I18n.t('advice_pages.nav.overview'), href: school_group_advice_path(school_group))
          end
        end

        it 'has the correct title' do
          expect(page).to have_content(report.title)
        end

        it 'displays the right breadcrumb' do
          expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq([I18n.t('common.schools'),
                                                                               school_group.name,
                                                                               I18n.t('advice_pages.breadcrumbs.root'),
                                                                               I18n.t('school_groups.titles.comparisons'),
                                                                               report.title])
        end
      end

      context 'when viewing the report' do
        it_behaves_like 'a school comparison report' do
          let(:expected_report) { report }
        end

        it_behaves_like 'a school comparison report with a table' do
          let(:expected_report) { report }
          let(:expected_school) { school }
          let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, :baseload]) }
          headers = ['School', 'Percent increase on winter baseload over summer', 'Summer baseload kW',
                     'Winter baseload kW', 'Saving if same all year around (at latest tariff)']
          let(:expected_table) do
            [headers,
             ["#{school.name} [5]", '+100&percnt;', '2', '3', '£4'],
             ["Notes\n[5] The tariff has changed during the last year for this school. Savings are calculated using the " \
              'latest tariff but other £ values are calculated using the relevant tariff at the time']]
          end
          let(:expected_csv) do
            [headers, [school.name, '100', '2', '3', '4']]
          end
        end

        it_behaves_like 'a school comparison report with a chart' do
          let(:expected_report) { report }
        end
      end
    end
  end

  let!(:report) { create(:report, key: :seasonal_baseload_variation) }

  context 'with an organisation group' do
    let!(:school_group) { create(:school_group, public: true) }

    # has all fuel types and actual data for electricity
    let!(:school) do
      school = create(:school,
                      :with_fuel_configuration,
                      :with_meter_dates,
                      school_group: school_group,
                      reading_start_date: 1.year.ago,
                      number_of_pupils: 1)
      create(:energy_tariff, :with_flat_price, tariff_holder: school, start_date: nil, end_date: nil)
      create(:electricity_meter_with_validated_reading_dates,
             school:, start_date: 1.year.ago, end_date: Time.zone.today, reading: 0.5)
      school
    end

    it_behaves_like 'an access controlled group page' do
      let(:path) { comparison_reports_school_group_advice_path(school_group) }
    end

    before do
      create(:advice_page, key: :baseload)
      visit comparison_reports_school_group_advice_path(school_group)
    end

    it_behaves_like 'a group comparison report index and page'
  end

  context 'with a project group' do
    let!(:school_group) do
      create(:school_group,
             :with_grouping,
             group_type: :project,
             role: :project,
             schools: [school])
    end

    # has all fuel types and actual data for electricity
    let!(:school) do
      school = create(:school,
                      :with_school_group,
                      :with_fuel_configuration,
                      :with_meter_dates,
                      reading_start_date: 1.year.ago,
                      number_of_pupils: 1)
      create(:energy_tariff, :with_flat_price, tariff_holder: school, start_date: nil, end_date: nil)
      create(:electricity_meter_with_validated_reading_dates,
             school:, start_date: 1.year.ago, end_date: Time.zone.today, reading: 0.5)
      school
    end

    it_behaves_like 'an access controlled group page' do
      let(:path) { comparison_reports_school_group_advice_path(school_group) }
    end

    before do
      create(:advice_page, key: :baseload)
      visit comparison_reports_school_group_advice_path(school_group)
    end

    it_behaves_like 'a group comparison report index and page'
  end
end

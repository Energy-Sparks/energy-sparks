# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupEnergySummaryTableComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:school_group) { create(:school_group) }

  around do |example|
    travel_to Date.new(2025, 9, 26)
    ClimateControl.modify AWESOMEPRINT: 'off' do
      example.run
    end
  end

  let(:school_group_cluster) { create(:school_group_cluster, school_group: school_group) }

  let!(:school) do
    create(:school,
           :with_basic_configuration_single_meter_and_tariffs,
           school_group: school_group,
           school_group_cluster: school_group_cluster)
  end

  before do
    alert_type = create(:alert_type, fuel_type: nil, class_name: 'ManagementSummaryTable')
    rating = create(:alert_type_rating, alert_type: alert_type, management_dashboard_table_active: true, rating_from: 0, rating_to: 10)
    create(:alert_type_rating_content_version, alert_type_rating: rating)
    meter_collection = AggregateSchoolService.new(school).aggregate_school
    Schools::GenerateConfiguration.new(school, meter_collection).generate
    Alerts::GenerateAndSaveAlertsAndBenchmarks.new(school: school,
                                                   aggregate_school: meter_collection).perform
    Alerts::GenerateContent.new(school).perform
  end

  shared_examples 'it does not render' do
    it { expect(page).not_to have_css('div.dashboards-group-energy-summary-table-component') }
  end

  shared_examples 'it renders a table with usage figures' do
    it_behaves_like 'it contains the expected data table', aligned: false do
      let(:table_id) { '#school-group-recent-usage-electricity' }
      let(:expected_header) do
        [[
          I18n.t('common.school'),
          I18n.t(:start_date, scope: 'common.labels'),
          I18n.t(:end_date, scope: 'common.labels'),
          I18n.t(:last_week, scope: 'common.labels'),
          I18n.t(:last_month, scope: 'common.labels'),
          I18n.t(:last_year, scope: 'common.labels')
        ]]
      end
      let(:expected_rows) do
        [[
          school.name,
          '26 Sep 2024',
          '26 Sep 2025',
          '168',  # 0.5 kWh, 48 HH periods, 7 days
          '744',
          '8,740'
        ]]
      end
    end
  end

  context 'with default options' do
    before do
      render_inline(described_class.new(
                      school_group: school_group,
                      schools: school_group.schools,
                      fuel_type: :electricity,
                      metric: :usage
      ))
    end

    it { expect(page).to have_css('div.dashboards-group-energy-summary-table-component') }

    it_behaves_like 'it renders a table with usage figures'
  end

  context 'when showing clusters' do
    before do
      render_inline(described_class.new(
                      school_group: school_group,
                      schools: school_group.schools,
                      fuel_type: :electricity,
                      metric: :usage,
                      show_clusters: true
      ))
    end

    it_behaves_like 'it contains the expected data table', aligned: false do
      let(:table_id) { '#school-group-recent-usage-electricity' }
      let(:expected_header) do
        [[
          I18n.t('common.school'),
          I18n.t('school_groups.clusters.labels.cluster'),
          I18n.t(:start_date, scope: 'common.labels'),
          I18n.t(:end_date, scope: 'common.labels'),
          I18n.t(:last_week, scope: 'common.labels'),
          I18n.t(:last_month, scope: 'common.labels'),
          I18n.t(:last_year, scope: 'common.labels')
        ]]
      end
      let(:expected_rows) do
        [[
          school.name,
          school_group_cluster.name,
          '26 Sep 2024',
          '26 Sep 2025',
          '168',  # 0.5 kWh, 48 HH periods, 7 days
          '744',
          '8,740'
        ]]
      end
    end
  end

  context 'with limited periods' do
    before do
      render_inline(described_class.new(
                      school_group: school_group,
                      schools: school_group.schools,
                      fuel_type: :electricity,
                      metric: :usage,
                      periods: [:year]
      ))
    end

    it_behaves_like 'it contains the expected data table', aligned: false do
      let(:table_id) { '#school-group-recent-usage-electricity' }
      let(:expected_header) do
        [[
          I18n.t('common.school'),
          I18n.t(:start_date, scope: 'common.labels'),
          I18n.t(:end_date, scope: 'common.labels'),
          I18n.t(:last_year, scope: 'common.labels')
        ]]
      end
      let(:expected_rows) do
        [[
          school.name,
          '26 Sep 2024',
          '26 Sep 2025',
          '8,740'
        ]]
      end
    end
  end

  context 'with change metric' do
    before do
      render_inline(described_class.new(
                      school_group: school_group,
                      schools: school_group.schools,
                      fuel_type: :electricity,
                      metric: :change
      ))
    end

    it_behaves_like 'it contains the expected data table', aligned: false do
      let(:table_id) { '#school-group-recent-usage-electricity' }
      let(:expected_header) do
        [[
          I18n.t('common.school'),
          I18n.t(:start_date, scope: 'common.labels'),
          I18n.t(:end_date, scope: 'common.labels'),
          I18n.t(:last_week, scope: 'common.labels'),
          I18n.t(:last_month, scope: 'common.labels'),
          I18n.t(:last_year, scope: 'common.labels')
        ]]
      end
      let(:expected_rows) do
        [[
          school.name,
          '26 Sep 2024',
          '26 Sep 2025',
          '0.0%',
          'n/a',
          'n/a'
        ]]
      end
    end
  end

  context 'when there is school without data' do
    before do
      create(:school, school_group: school_group)
      render_inline(described_class.new(
                      school_group: school_group,
                      schools: school_group.schools,
                      fuel_type: :electricity,
                      metric: :usage
      ))
    end

    it_behaves_like 'it renders a table with usage figures'
  end

  context 'when there is a school with a currently failing regeneration' do
    # school has previously generated, but is now failing so it has a fuel configuration
    # but no current management dashboard table data
    let!(:failing_school) { create(:school, :with_fuel_configuration, school_group: school_group)}

    before do
      render_inline(described_class.new(
                      school_group: school_group,
                      schools: school_group.schools,
                      fuel_type: :electricity,
                      metric: :usage
      ))
    end

    it_behaves_like 'it contains the expected data table', aligned: false do
      let(:table_id) { '#school-group-recent-usage-electricity' }
      let(:expected_header) do
        [[
          I18n.t('common.school'),
          I18n.t(:start_date, scope: 'common.labels'),
          I18n.t(:end_date, scope: 'common.labels'),
          I18n.t(:last_week, scope: 'common.labels'),
          I18n.t(:last_month, scope: 'common.labels'),
          I18n.t(:last_year, scope: 'common.labels')
        ]]
      end
      let(:expected_rows) do
        [
          [school.name, '26 Sep 2024', '26 Sep 2025', '168', '744', '8,740'],
          [failing_school.name, '', '', '-', '-', '-']
        ]
      end
    end
  end

  context 'when there are no data enabled schools in group' do
    let!(:school) do
      create(:school,
             :with_basic_configuration_single_meter_and_tariffs,
             school_group: school_group,
             data_enabled: false)
    end

    before do
      render_inline(described_class.new(
                      school_group: school_group,
                      schools: school_group.schools,
                      fuel_type: :electricity,
                      metric: :usage
      ))
    end

    it_behaves_like 'it does not render'
  end

  context 'when there are no schools in group' do
    let!(:school) do
      create(:school,
             :with_basic_configuration_single_meter_and_tariffs,
             school_group: create(:school_group))
    end

    before do
      render_inline(described_class.new(
                      school_group: school_group,
                      schools: school_group.schools,
                      fuel_type: :electricity,
                      metric: :usage
      ))
    end

    it_behaves_like 'it does not render'
  end
end

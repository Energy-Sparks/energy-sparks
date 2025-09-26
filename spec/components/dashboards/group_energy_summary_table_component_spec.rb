# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupEnergySummaryTableComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:school_group) { create(:school_group) }

  around do |example|
    ClimateControl.modify AWESOMEPRINT: 'off' do
      example.run
    end
  end

  let!(:school) do
    create(:school,
           :with_basic_configuration_single_meter_and_tariffs,
           school_group: school_group)
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

  let(:html) do
    render_inline(described_class.new(
                    school_group: school_group,
                    schools: school_group.schools,
                    fuel_type: :electricity,
                    metric: :usage
    ))
  end

  context 'with default options' do
    it 'has the expected header' do
      expect(html).to have_css('table thead tr th', text: I18n.t(:last_week, scope: 'common.labels'))
      expect(html).to have_css('table thead tr th', text: I18n.t(:last_month, scope: 'common.labels'))
      expect(html).to have_css('table thead tr th', text: I18n.t(:last_year, scope: 'common.labels'))
    end

    it 'has the expected cells' do
      expect(html).to have_css('table tbody tr td', text: school.name)
      expect(html).to have_css('table tbody tr td', text: '168') # 0.5 kWh, 48 HH periods, 7 days
      expect(html).to have_css('table tbody tr td', text: '744')
      expect(html).to have_css('table tbody tr td', text: '8,740')
    end
  end

  context 'with change metric' do
    let(:html) do
      render_inline(described_class.new(
                      school_group: school_group,
                      schools: school_group.schools,
                      fuel_type: :electricity,
                      metric: :change
      ))
    end

    it 'has the expected header' do
      expect(html).to have_css('table thead tr th', text: I18n.t(:last_week, scope: 'common.labels'))
      expect(html).to have_css('table thead tr th', text: I18n.t(:last_month, scope: 'common.labels'))
      expect(html).to have_css('table thead tr th', text: I18n.t(:last_year, scope: 'common.labels'))
    end

    it 'has the expected cells' do
      expect(html).to have_css('table tbody tr td', text: school.name)
      expect(html).to have_css('table tbody tr td', text: '0.0%')
      expect(html).to have_css('table tbody tr td', text: 'n/a')
    end
  end

  context 'when there is a non data enabled school' do
    let!(:other_school) { create(:school, school_group: school_group) }

    it 'does not include school' do
      expect(html).not_to have_content(other_school.name)
    end
  end
end

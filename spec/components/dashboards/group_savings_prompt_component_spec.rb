# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboards::GroupSavingsPromptComponent, :include_url_helpers, type: :component do
  subject(:html) do
    render_inline(described_class.new(**params))
  end

  let(:school_group) { create(:school_group, :with_active_schools, count: 2) }
  let(:metric) { :kwh }

  let(:params) do
    {
      school_group: school_group,
      schools: school_group.schools,
      metric: metric,
      id: 'custom-id',
      classes: 'extra-classes'
    }
  end

  before do
    alert_type = create(:alert_type, fuel_type: :gas, frequency: :weekly)
    create(:alert_type_rating_content_version,
                             alert_type_rating: create(:alert_type_rating,
                                                       alert_type: alert_type,
                                                       management_priorities_active: true,
                                                       description: 'high'),
                              management_priorities_title: 'Spending too much money on heating'
    )

    school_group.schools.each do |school|
      create(:alert, :with_run,
        alert_type: alert_type,
        run_on: Time.zone.today, school: school,
        rating: 2.0,
        template_data: {
          average_one_year_saving_£: '£1,000',
          one_year_saving_co2: '1,100 kg CO2',
          one_year_saving_kwh: '1,111 kWh'
        }
      )
      Alerts::GenerateContent.new(school).perform
    end
  end

  context 'with priority actions' do
    it_behaves_like 'an application component' do
      let(:expected_classes) { 'extra-classes' }
      let(:expected_id) { 'custom-id' }
    end

    it { expect(html).to have_content('Spending too much money on heating') }
    it { expect(html).to have_content('gas') }
    it { expect(html).to have_content('2 schools') }
    it { expect(html).to have_content('2,222 kWh') }

    context 'when displaying co2' do
      let(:metric) { :co2 }

      it { expect(html).to have_content('2,200 kg CO2') }
    end

    context 'when displaying gbp' do
      let(:metric) { :gbp }

      it { expect(html).to have_content('£2,000') }
    end
  end
end

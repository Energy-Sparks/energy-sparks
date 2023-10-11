require 'rails_helper'

describe 'Alert' do
  let(:alert_type_description) { 'all about this alert type' }
  let(:gas_fuel_alert_type)             { create(:alert_type, fuel_type: :gas, frequency: :termly, description: alert_type_description) }
  let(:electricity_fuel_alert_type)     { create(:alert_type, fuel_type: :electricity, frequency: :termly, description: alert_type_description) }
  let(:school)                          { create(:school) }

  it 'ignores alerts if there is an exception' do
    alert_1 = create(:alert, school: school, alert_type: gas_fuel_alert_type, created_at: Date.today)
    alert_2 = create(:alert, school: school, alert_type: electricity_fuel_alert_type, created_at: Date.today)

    expect(Alert.without_exclusions).to eq([alert_1, alert_2])

    SchoolAlertTypeExclusion.create(school: school, alert_type: gas_fuel_alert_type)
    expect(Alert.without_exclusions).to eq([alert_2])
  end

  it 'has a rating of unrated if no rating is et' do
    no_rating_alert = create(:alert, rating: nil)
    expect(no_rating_alert.formatted_rating).to eq 'Unrated'
  end

  context 'when loading alert variables' do
    let(:template_data) do
      {
        'urn' => '1234',
        'timescale' => 'last 2 years'
      }
    end
    let(:template_data_cy) do
      {
        'urn' => '1234',
        'timescale' => '2 flynedd diwethaf'
      }
    end
    let!(:alert) { create(:alert, school: school, alert_type: electricity_fuel_alert_type, created_at: Date.today, template_data: template_data, template_data_cy: template_data_cy) }

    it 'returns welsh template data for cy locale' do
      I18n.with_locale(:cy) do
        expect(Alert.first.template_variables).to eq(
          {
            urn: '1234',
            timescale: '2 flynedd diwethaf'
          }
        )
      end
    end

    it 'returns english if welsh data is empty' do
      alert.update!(template_data_cy: nil)
      expect(Alert.first.template_variables).to eq(
        {
          urn: '1234',
          timescale: 'last 2 years'
        }
      )
      alert.update!(template_data_cy: {})
      expect(Alert.first.template_variables).to eq(
        {
          urn: '1234',
          timescale: 'last 2 years'
        }
      )
    end

    it 'returns english template data for other locales' do
      expect(Alert.first.template_variables).to eq(
        {
          urn: '1234',
          timescale: 'last 2 years'
        }
      )
    end
  end
end

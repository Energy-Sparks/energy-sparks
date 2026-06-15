require 'rails_helper'

describe Alert do
  let(:alert_type_description) { 'all about this alert type' }
  let(:gas_fuel_alert_type)             { create(:alert_type, fuel_type: :gas, frequency: :termly, description: alert_type_description) }
  let(:electricity_fuel_alert_type)     { create(:alert_type, fuel_type: :electricity, frequency: :termly, description: alert_type_description) }
  let(:school)                          { create(:school) }

  it 'ignores alerts if there is an exception' do
    alert_1 = create(:alert, school: school, alert_type: gas_fuel_alert_type, created_at: Time.zone.today)
    alert_2 = create(:alert, school: school, alert_type: electricity_fuel_alert_type, created_at: Time.zone.today)

    expect(Alert.without_exclusions).to match_array([alert_1, alert_2])

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
    let!(:alert) { create(:alert, school: school, alert_type: electricity_fuel_alert_type, created_at: Time.zone.today, template_data: template_data, template_data_cy: template_data_cy) }

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

  describe '#summarised_alerts' do
    context 'with valid data' do
      subject(:results) do
        described_class.summarised_alerts(schools: schools)
      end

      let(:schools) { create_list(:school, 2) }

      let(:alert_type) { create(:alert_type) }
      let(:content_version) do
        create(:alert_type_rating_content_version,
               alert_type_rating: create(:alert_type_rating,
                                         alert_type: alert_type,
                                         group_dashboard_alert_active: true,
                                         rating_from: 6.0,
                                         rating_to: 10.0))
      end

      let(:variables) do
        {
          one_year_saving_kwh: 1.0,
          average_one_year_saving_gbp: 2.0,
          one_year_saving_co2: 3.0,
          time_of_year_relevance: 5.0
        }
      end

      before do
        create(:alert,
               school: schools.first,
               alert_generation_run: create(:alert_generation_run, school: schools.first),
               alert_type: content_version.alert_type_rating.alert_type,
               rating: 6.0,
               variables: variables)
        create(:alert,
               school: schools.last,
               alert_generation_run: create(:alert_generation_run, school: schools.last),
               alert_type: content_version.alert_type_rating.alert_type,
               rating: 7.0,
               variables: variables)
      end

      it 'returns data for correct schools' do
        expect(described_class.summarised_alerts(schools: [create(:school)])).to be_empty
      end

      it 'returns correctly calculated data' do
        result = results.first
        expect(result.number_of_schools).to eq(2)
        expect(result.time_of_year_relevance).to eq(5.0)
        expect(result.average_rating).to eq(6.5)
        expect(result.total_one_year_saving_kwh).to eq(2.0)
        expect(result.total_average_one_year_saving_gbp).to eq(4.0)
        expect(result.total_one_year_saving_co2).to eq(6.0)
        expect(result.alert_type_rating).to eq(content_version.alert_type_rating)
        expect(result.alert_type).to eq(content_version.alert_type_rating.alert_type)
      end

      context 'when there is no AlertTypeRating for rating' do
        let(:content_version) do
          create(:alert_type_rating_content_version,
                 alert_type_rating: create(:alert_type_rating,
                                           alert_type: alert_type,
                                           group_dashboard_alert_active: true,
                                           rating_from: 9.0,
                                           rating_to: 10.0))
        end

        it 'returns nothing' do
          expect(results).to be_empty
        end
      end

      context 'when the alert rating is not active on group dashboards' do
        let(:content_version) do
          create(:alert_type_rating_content_version,
                 alert_type_rating: create(:alert_type_rating,
                                           alert_type: alert_type,
                                           group_dashboard_alert_active: false,
                                           rating_from: 6.0,
                                           rating_to: 10.0))
        end

        it 'returns nothing' do
          expect(results).to be_empty
        end
      end

      context 'when there are missing variables' do
        let(:variables) do
          {
            average_one_year_saving_gbp: 2.0,
            one_year_saving_co2: 3.0,
            time_of_year_relevance: 5.0
          }
        end

        it 'removes those alerts' do
          expect(results).to be_empty
        end
      end
    end
  end
end

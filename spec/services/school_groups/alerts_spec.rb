require 'rails_helper'

RSpec.describe SchoolGroups::Alerts do
  subject(:alerts) { described_class.new(school_group.schools).summarise }

  let(:school_group) { create(:school_group, :with_active_schools, count: 2) }
  let(:alert_type) { create(:alert_type) }
  let(:alert_type_rating) do
    create(:alert_type_rating,
           group_dashboard_alert_active: true,
           alert_type: alert_type,
           rating_from: 6.0,
           rating_to: 10.0)
  end

  let(:content_version) do
    create(:alert_type_rating_content_version,
           colour: :negative,
           alert_type_rating: alert_type_rating)
  end

  context 'when there is invalid data' do
    before do
      school_group.schools.each_with_index do |school, index|
        create(:alert,
               school: school,
               alert_generation_run: create(:alert_generation_run, school: school),
               alert_type: content_version.alert_type_rating.alert_type,
               rating: 6.0,
               variables: {
                     one_year_saving_kwh: index == 0 ? nil : 1.0,
                     average_one_year_saving_gbp: 2.0,
                     one_year_saving_co2: 3.0,
                     time_of_year_relevance: 5.0
               })
      end
    end

    it 'returns summary for just the records with valid data' do
      expect(alerts.first.number_of_schools).to eq(1)
    end
  end

  context 'when there are alerts to display' do
    before do
      school_group.schools.each do |school|
        create(:alert,
               school: school,
               alert_generation_run: create(:alert_generation_run, school: school),
               alert_type: content_version.alert_type_rating.alert_type,
               rating: 6.0,
               variables: {
                     one_year_saving_kwh: 1.0,
                     average_one_year_saving_gbp: 2.0,
                     one_year_saving_co2: 3.0,
                     time_of_year_relevance: 5.0
               })
      end
    end

    it 'returns the expected alert' do
      expect(alerts.first.alert_type).to eq(alert_type)
      expect(alerts.first.alert_type_rating).to eq(alert_type_rating)
      expect(alerts.first.number_of_schools).to eq(school_group.schools.count)
    end

    context 'when there are multiple alerts for the same alert type' do
      before do
        school = create(:school, school_group: school_group)
        version = create(:alert_type_rating_content_version,
               colour: :positive,
               alert_type_rating: create(:alert_type_rating,
                                         group_dashboard_alert_active: true,
                                         alert_type: alert_type,
                                         rating_from: 0.0,
                                         rating_to: 4.0))
        create(:alert,
               school: school,
               alert_generation_run: create(:alert_generation_run, school: school),
               alert_type: version.alert_type_rating.alert_type,
               rating: 2.0,
               variables: {
                     one_year_saving_kwh: 1.0,
                     average_one_year_saving_gbp: 2.0,
                     one_year_saving_co2: 3.0,
                     time_of_year_relevance: 5.0
               })
      end

      it 'returns the alert with most schools' do
        expect(alerts.first.alert_type_rating).to eq(alert_type_rating)
        expect(alerts.first.number_of_schools).to eq(2)
      end
    end
  end
end

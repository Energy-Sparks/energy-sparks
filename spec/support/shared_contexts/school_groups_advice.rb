RSpec.shared_context 'with a group dashboard alert' do
  let(:dashboard_alert_content) do
    create(:alert_type_rating_content_version,
           colour: :negative,
           group_dashboard_title: 'Spending too much money on gas',
           alert_type_rating: create(:alert_type_rating,
                                     group_dashboard_alert_active: true,
                                     alert_type: create(:alert_type),
                                     rating_from: 6.0,
                                     rating_to: 10.0))
  end

  before do
    schools.each do |school|
      alert_run = school.latest_alert_run || create(:alert_generation_run, school: school)
      create(:alert,
             school: school,
             alert_generation_run: alert_run,
             alert_type: dashboard_alert_content.alert_type_rating.alert_type,
             rating: 6.0,
             variables: {
                   one_year_saving_kwh: 1.0,
                   average_one_year_saving_gbp: 2.0,
                   one_year_saving_co2: 3.0,
                   time_of_year_relevance: 5.0
             })
    end
  end
end

RSpec.shared_context 'with a group management priority' do
  let(:priority_alert_type_rating) do
    create(:alert_type_rating,
           management_priorities_active: true,
           alert_type: create(:alert_type),
           rating_from: 6.0,
           rating_to: 10.0)
  end

  before do
    content_version = create(:alert_type_rating_content_version,
               colour: :negative,
               management_priorities_title: 'Spending too much money on heating',
               alert_type_rating: priority_alert_type_rating)
    schools.each do |school|
      alert_run = school.latest_alert_run || create(:alert_generation_run, school: school)
      create(:alert,
             school: school,
             alert_generation_run: alert_run,
             alert_type: content_version.alert_type_rating.alert_type,
             run_on: Time.zone.today,
             rating: 6.0,
             template_data: {
                   one_year_saving_kwh: '2,200 kWh',
                   average_one_year_saving_£: '£1,000',
                   one_year_saving_co2: '1,100 kg CO2',
                   time_of_year_relevance: 5.0
             })
      Alerts::GenerateContent.new(school).perform
    end
  end
end

RSpec.shared_context 'with dashboard alerts' do
  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:gas_alert) do
    alert_type = create(:alert_type, fuel_type: :gas)
    alert_type_rating = create(
      :alert_type_rating,
      alert_type: alert_type,
      rating_from: 0,
      rating_to: 10,
      management_dashboard_alert_active: true,
      pupil_dashboard_alert_active: true,
    )
    create(
      :alert_type_rating_content_version,
      alert_type_rating: alert_type_rating,
      management_dashboard_title_en: 'You can save {{average_one_year_saving_gbp}} on heating in {{average_payback_years}}',
      management_dashboard_title_cy: 'Gallwch arbed {{average_one_year_saving_gbp}} mewn {{average_payback_years}}',
      pupil_dashboard_title_en: 'You can save {{average_one_year_saving_gbp}} on heating in {{average_payback_years}}',
      pupil_dashboard_title_cy: 'Gallwch arbed {{average_one_year_saving_gbp}} mewn {{average_payback_years}}',
    )
    create(:alert, :with_run,
      alert_type: alert_type,
      alert_generation_run: alert_run,
      run_on: Time.zone.today,
      school: school,
      rating: 9.0,
      template_data: {
        average_one_year_saving_gbp: '£5,000',
        average_payback_years: '1 year'
      },
      template_data_cy: {
        average_one_year_saving_gbp: '£7,000',
        average_payback_years: '1 flwyddyn'
      }
    )
  end

  let!(:electricity_alert) do
    alert_type = create(:alert_type, fuel_type: :electricity)
    alert_type_rating = create(
      :alert_type_rating,
      alert_type: alert_type,
      rating_from: 0,
      rating_to: 10,
      management_dashboard_alert_active: true,
      pupil_dashboard_alert_active: false,
    )
    create(
      :alert_type_rating_content_version,
      alert_type_rating: alert_type_rating,
      management_dashboard_title_en: 'Your baseload is high and is costing {{average_one_year_saving_gbp}}',
      management_dashboard_title_cy: 'Mae eich llwyth sylfaenol yn uchel ac yn costio {{average_one_year_saving_gbp}}',
      pupil_dashboard_title_en: 'Your baseload is high and is costing {{average_one_year_saving_gbp}}',
      pupil_dashboard_title_cy: 'Mae eich llwyth sylfaenol yn uchel ac yn costio {{average_one_year_saving_gbp}}',
    )
    create(:alert, :with_run,
      alert_type: alert_type,
      alert_generation_run: alert_run,
      run_on: Time.zone.today,
      school: school,
      rating: 9.0,
      template_data: {
        average_one_year_saving_gbp: '£5,000',
        average_payback_years: '1 year'
      },
      template_data_cy: {
        average_one_year_saving_gbp: '£7,000',
        average_payback_years: '1 flwyddyn'
      }
    )
  end

  before do
    Alerts::GenerateContent.new(school).perform
  end
end

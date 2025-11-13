# frozen_string_literal: true

require 'rails_helper'

describe 'Gas anomaly report' do
  let(:meter) do
    school = create(:school, :with_calendar,
               school_group: create(:school_group, default_issues_admin_user: create(:admin)),
               weather_station: create(:weather_station))
    create(:gas_meter, school: school)
  end

  let(:anomaly) { Report::GasAnomaly.first }

  before do
    current_day = Date.yesterday
    previous_day = current_day - 7.days
    temperatures = Array.new(48, rand(15.0..16.0))
    create(:weather_observation,
           weather_station: meter.school.weather_station,
           reading_date: current_day,
           temperature_celsius_x48: temperatures)
    create(:weather_observation,
           weather_station: meter.school.weather_station,
           reading_date: previous_day,
           temperature_celsius_x48: temperatures)

    event_type = create(:calendar_event_type, :term_time, title: 'Term')
    create(:calendar_event,
           calendar: meter.school.calendar,
           calendar_event_type: event_type,
           start_date: current_day, end_date: current_day)
    create(:calendar_event,
           calendar: meter.school.calendar,
           calendar_event_type: event_type,
           start_date: previous_day, end_date: previous_day)

    create(:amr_validated_reading, meter: meter, reading_date: current_day, one_day_kwh: 500.0)
    create(:amr_validated_reading, meter: meter, reading_date: previous_day, one_day_kwh: 1.0)

    Report::GasAnomaly.refresh
    sign_in(create(:admin))
    visit admin_reports_path
    click_on 'Gas anomalies'
  end

  it_behaves_like 'an admin meter report' do
    let(:title) { 'Gas usage anomalies' }
    let(:description) { 'Gas meters that have unusually high readings' }
    let(:frequency) { :daily }
  end

  it 'displays the table' do
    rows = all('tr').map { |tr| tr.all('th, td').map(&:text) }
    today_temp = FormatUnit.format(:temperature, anomaly.today_temperature.to_f, :html, false, true, :benchmark)
    prev_temp = FormatUnit.format(:temperature, anomaly.previous_temperature.to_f, :html, false, true, :benchmark)

    expect(rows).to eq([
                         ['School Group', 'Admin', 'School', 'Meter', 'Meter Name', 'Reading Date', 'Kwh', 'Previous Kwh', 'Temperature', 'Previous Temperature', 'Period', 'Chart'],
                         [meter.school_group.name, meter.school_group&.default_issues_admin_user&.name, meter.school.name, meter.mpan_mprn.to_s, meter.name, anomaly.reading_date.iso8601, '500', '1', today_temp, prev_temp, 'Term', 'Chart']
                       ])
  end

  it 'allows csv download' do
    click_on 'CSV'
    today_temp = FormatUnit.format(:temperature, Report::GasAnomaly.first.today_temperature.to_f, :html, false, true, :benchmark)
    prev_temp = FormatUnit.format(:temperature, Report::GasAnomaly.first.previous_temperature.to_f, :html, false, true, :benchmark)

    expect(page.response_headers['content-type']).to eq('text/csv')
    expect(body).to \
      eq("School Group,Admin,School,Meter,Meter Name,Reading Date,Kwh,Previous Kwh,Temperature,Previous Temperature,Period\n" \
         "#{meter.school_group.name},#{meter.school_group&.default_issues_admin_user&.name},#{meter.school.name},#{meter.mpan_mprn},#{meter.name},#{anomaly.reading_date.iso8601},500,1,#{today_temp},#{prev_temp},Term\n")
  end
end

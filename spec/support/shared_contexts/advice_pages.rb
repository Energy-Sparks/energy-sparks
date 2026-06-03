RSpec.shared_context 'advice page base' do
  let(:learn_more_content) { 'Learn more content' }
  let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true, has_solar_pv: true)}
  let(:school) { create(:school, school_group: create(:school_group)) }

  let(:caveats_service) do
    instance_double(Costs::EconomicTariffsChangeCaveatsService,
                    calculate_economic_tariff_changed: OpenStruct.new(
                      last_change_date: Date.new(2022, 9, 1),
                      percent_change: 18.857098661736725,
                      rate_after_£_per_kwh: 3.066783066364631,
                      rate_before_£_per_kwh: 0.1544426564326899
                        ))
  end

  before do
    allow(Costs::EconomicTariffsChangeCaveatsService).to receive(:new).and_return(caveats_service)
    school.configuration.update!(fuel_configuration: fuel_configuration)
  end
end

RSpec.shared_context 'advice page' do
  include_context 'advice page base'
  let!(:advice_page) { create(:advice_page, key: key, restricted: false, learn_more: learn_more_content) }
end

RSpec.shared_context 'electricity advice page' do
  let(:fuel_type) { :electricity }
  include_context 'advice page base'
  let!(:advice_page) { create(:advice_page, key: key, restricted: false, fuel_type: fuel_type, learn_more: learn_more_content) }

  let(:start_date)  { Time.zone.today - 366}
  let(:end_date)    { Time.zone.today - 1}
  let(:amr_data)    { double('amr-data') }

  let(:aggregate_meter) { double('electricity-aggregated-meter') }
  let(:meter_collection) { double('meter-collection', electricity_meters: [build(:meter, type: :electricity)], solar_pv_panels?: true) }

  before do
    school.configuration.update!(
      fuel_configuration: fuel_configuration,
      aggregate_meter_dates: {
        electricity: {
          start_date: start_date.iso8601,
          end_date: end_date.iso8601
        }
      }
    )
    allow(amr_data).to receive(:start_date).and_return(start_date)
    allow(amr_data).to receive(:end_date).and_return(end_date)
    allow(amr_data).to receive(:kwh_date_range).and_return(nil)
    allow(aggregate_meter).to receive(:fuel_type).and_return(:electricity)
    allow(aggregate_meter).to receive(:amr_data).and_return(amr_data)
    allow(aggregate_meter).to receive(:mpan_mprn).and_return(912345)
    allow(meter_collection).to receive(:aggregate_meter).with(:electricity).and_return(aggregate_meter)
    allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(aggregate_meter)
    allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(meter_collection)
  end
end

RSpec.shared_context 'gas advice page' do
  let(:fuel_type) { :gas }
  include_context 'advice page base'

  let!(:advice_page) { create(:advice_page, key: key, restricted: false, fuel_type: fuel_type, learn_more: learn_more_content) }

  let(:start_date)  { Time.zone.today - 366}
  let(:end_date)    { Time.zone.today - 1}
  let(:amr_data)    { double('amr-data') }

  let(:aggregate_meter) { double('gas-aggregated-meter')}
  let(:meter_collection) { double('meter-collection', heater_meters: []) }

  before do
    school.configuration.update!(
      fuel_configuration: fuel_configuration,
      aggregate_meter_dates: {
        gas: {
          start_date: start_date.iso8601,
          end_date: end_date.iso8601
        }
      }
    )
    allow(amr_data).to receive(:start_date).and_return(start_date)
    allow(amr_data).to receive(:end_date).and_return(end_date)
    allow(amr_data).to receive(:kwh_date_range).and_return(nil)
    allow(aggregate_meter).to receive(:fuel_type).and_return(:gas)
    allow(aggregate_meter).to receive(:amr_data).and_return(amr_data)
    allow(meter_collection).to receive(:aggregate_meter).with(:gas).and_return(aggregate_meter)
    allow(meter_collection).to receive(:aggregated_heat_meters).and_return(aggregate_meter)
    allow(meter_collection).to receive(:amr_data).and_return(amr_data)
    allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(meter_collection)
  end
end

RSpec.shared_context 'solar advice page' do
  let(:fuel_type) { :solar_pv }
  include_context 'advice page base'
  let!(:advice_page) { create(:advice_page, key: key, restricted: false, fuel_type: fuel_type, learn_more: learn_more_content) }

  let(:start_date)  { Time.zone.today - 366}
  let(:end_date)    { Time.zone.today - 1}
  let(:amr_data)    { double('amr-data') }

  let(:electricity_aggregate_meter)   { double('electricity-aggregated-meter')}
  let(:meter_collection)              { double('meter-collection', electricity_meters: [], solar_pv_panels?: true) }

  before do
    school.configuration.update!(
      fuel_configuration: fuel_configuration,
      aggregate_meter_dates: {
        electricity: {
          start_date: start_date.iso8601,
          end_date: end_date.iso8601
        }
      }
    )
    allow(amr_data).to receive(:start_date).and_return(start_date)
    allow(amr_data).to receive(:end_date).and_return(end_date)
    allow(electricity_aggregate_meter).to receive(:fuel_type).and_return(:electricity)
    allow(electricity_aggregate_meter).to receive(:amr_data).and_return(amr_data)
    allow(meter_collection).to receive(:aggregate_meter).with(:electricity).and_return(electricity_aggregate_meter)
    allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(electricity_aggregate_meter)
    allow(meter_collection).to receive(:amr_data).and_return(amr_data)
    allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(meter_collection)
  end
end

RSpec.shared_context 'storage advice page' do
  let(:fuel_type) { :storage_heater }
  include_context 'advice page base'
  # let(:fuel_type) { :solar_pv }
  # include_context "advice page base"
  let!(:advice_page) { create(:advice_page, key: key, restricted: false, fuel_type: fuel_type, learn_more: learn_more_content) }
  let(:start_date)  { Time.zone.today - 366}
  let(:end_date)    { Time.zone.today - 1}
  let(:amr_data)    { double('amr-data') }
  let(:electricity_aggregate_meter)   { double('electricity-aggregated-meter')}
  let(:meter_collection)              { double('meter-collection', electricity_meters: []) }
  let(:storage_heater_meter) { double('storage-heater-meter')}

  before do
    school.configuration.update!(
      fuel_configuration: fuel_configuration,
      aggregate_meter_dates: {
        electricity: {
          start_date: start_date.iso8601,
          end_date: end_date.iso8601
        },
        storage_heater: {
          start_date: start_date.iso8601,
          end_date: end_date.iso8601
        }
      }
    )
    allow(amr_data).to receive(:start_date).and_return(start_date)
    allow(amr_data).to receive(:end_date).and_return(end_date)
    allow(electricity_aggregate_meter).to receive(:fuel_type).and_return(:electricity)
    allow(electricity_aggregate_meter).to receive(:amr_data).and_return(amr_data)
    allow(storage_heater_meter).to receive(:fuel_type).and_return(:storage_heater)
    allow(meter_collection).to receive(:aggregate_meter).and_return(storage_heater_meter)
    allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(electricity_aggregate_meter)
    allow(meter_collection).to receive(:storage_heater_meter).and_return(storage_heater_meter)
    allow(meter_collection).to receive(:amr_data).and_return(amr_data)
    allow(storage_heater_meter).to receive(:amr_data).and_return(amr_data)
    allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(meter_collection)
  end
end

RSpec.shared_context 'displayable alert content' do
  let(:template_data) { {} }
  let(:template_data_cy) { {} }
  let(:alert_text) { 'Expected alert content' }
  let(:alert_text_cy) { 'Welsh alert content' }

  before do
    alert_type_rating = create(
      :alert_type_rating,
      alert_type: alert_type,
      rating_from: 0,
      rating_to: 10,
      management_dashboard_alert_active: true,
    )
    create(
      :alert_type_rating_content_version,
      alert_type_rating: alert_type_rating,
      management_dashboard_title_en: alert_text,
      management_dashboard_title_cy: alert_text_cy,
    )
    create(:alert, :with_run,
      alert_type: alert_type,
      run_on: Time.zone.today,
      school: school,
      rating: 5.0,
      template_data: template_data,
      template_data_cy: template_data_cy
    )
    Alerts::GenerateContent.new(school).perform
  end
end

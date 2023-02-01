RSpec.shared_context "advice page" do
  let!(:advice_page) { create(:advice_page, key: key, restricted: false, fuel_type: :electricity, learn_more: "Learn more content") }
  let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true)}
  let(:school) { create(:school, school_group: create(:school_group)) }
  before do
    school.configuration.update!(fuel_configuration: fuel_configuration)
  end
end

RSpec.shared_context "electricity advice page" do
  let(:fuel_type) { :electricity }
  include_context "advice page"

  let(:start_date)  { Date.today - 365}
  let(:end_date)    { Date.today - 1}
  let(:amr_data)    { double('amr-data') }

  let(:electricity_aggregate_meter)   { double('electricity-aggregated-meter')}
  let(:meter_collection)              { double('meter-collection', electricity_meters: []) }

  before do
    school.configuration.update!(fuel_configuration: fuel_configuration)
    allow(amr_data).to receive(:start_date).and_return(start_date)
    allow(amr_data).to receive(:end_date).and_return(end_date)
    allow(electricity_aggregate_meter).to receive(:fuel_type).and_return(:electricity)
    allow(electricity_aggregate_meter).to receive(:amr_data).and_return(amr_data)
    allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(electricity_aggregate_meter)
    allow(meter_collection).to receive(:amr_data).and_return(amr_data)
    allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(meter_collection)
  end
end

RSpec.shared_context "gas advice page" do
  let(:fuel_type) { :gas }
  include_context "advice page"
  # creating page with no fuel type for now as this breaks gas pages. Assume other context is required.
  let!(:advice_page) { create(:advice_page, key: key, restricted: false, learn_more: "Learn more content") }
end

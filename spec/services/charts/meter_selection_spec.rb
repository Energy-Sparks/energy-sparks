require 'rails_helper'

describe Charts::MeterSelection do
  subject(:selection) { described_class.new(school, aggregate_school_service, :electricity) }

  let(:school) { create(:school) }

  let(:aggregate_school_service) do
    instance_double(AggregateSchoolService, aggregate_school: meter_collection)
  end

  let(:meter_collection) do
    build(:meter_collection, :with_aggregate_meter, fuel_type: :electricity)
  end

  let(:meters) do
    build_list(:meter, 3, type: :electricity)
  end

  before do
    meters.each do |meter|
      meter_collection.add_electricity_meter(meter)
    end
  end

  describe '#meter_selection_options' do
    it 'returns displayable meters plus whole school by default' do
      expect(selection.meter_selection_options.length).to eq(4)

      expect(selection.meter_selection_options.first.mpan_mprn).to eq(meter_collection.aggregate_meter(:electricity).mpan_mprn)
      expect(selection.meter_selection_options.first.display_name).to eq(I18n.t('advice_pages.charts.whole_school'))

      expect(selection.meter_selection_options[1..]).to eq(meters.sort_by(&:mpan_mprn))
    end

    it 'returns only meters with data' do
      meters.first.amr_data.clear
      expect(selection.meter_selection_options.length).to eq(3)
      expect(selection.meter_selection_options[1..]).to eq(meters[1..].sort_by(&:mpan_mprn))
    end

    context 'with a filter' do
      subject(:selection) { described_class.new(school, aggregate_school_service, :electricity, filter: :non_heating_only?) }

      it 'applies the filter' do
        allow(meters.first).to receive(:non_heating_only?).and_return(true)
        expect(selection.meter_selection_options.length).to eq(3)
        expect(selection.meter_selection_options[1..]).to eq(meters[1..].sort_by(&:mpan_mprn))
      end
    end

    context 'with a fuel type' do
      subject(:selection) { described_class.new(school, aggregate_school_service, :gas, include_whole_school: false) }

      it 'selects the correct meters' do
        expect(selection.meter_selection_options).to be_empty
      end
    end
  end

  describe '#date_ranges_by_meter' do
    it 'returns the expected dates' do
      aggregate_meter = meter_collection.aggregate_meter(:electricity)
      expect(selection.date_ranges_by_meter.keys).to eq([aggregate_meter.mpan_mprn] + meters.map(&:mpan_mprn))

      whole_school = selection.date_ranges_by_meter[aggregate_meter.mpan_mprn]
      expect(whole_school[:start_date]).to eq(aggregate_meter.amr_data.start_date)
      expect(whole_school[:end_date]).to eq(aggregate_meter.amr_data.end_date)

      first_meter = selection.date_ranges_by_meter[meters.first.mpan_mprn]
      expect(first_meter[:start_date]).to eq(meters.first.amr_data.start_date)
      expect(first_meter[:end_date]).to eq(meters.first.amr_data.end_date)
    end

    context 'with window' do
      subject(:selection) { described_class.new(school, aggregate_school_service, :electricity, date_window: 10) }

      it 'returns the expected dates' do
        # electricity meters have 30 days by default, the aggregate will have 8 days
        # checks windows and start dates are correct
        aggregate_meter = meter_collection.aggregate_meter(:electricity)
        whole_school = selection.date_ranges_by_meter[aggregate_meter.mpan_mprn]
        expect(whole_school[:start_date]).to eq(aggregate_meter.amr_data.start_date)
        expect(whole_school[:end_date]).to eq(aggregate_meter.amr_data.end_date)

        first_meter = selection.date_ranges_by_meter[meters.first.mpan_mprn]
        expect(first_meter[:start_date]).to eq(meters.first.amr_data.end_date - 10)
        expect(first_meter[:end_date]).to eq(meters.first.amr_data.end_date)
      end
    end
  end

  describe '#underlying_meters' do
    it 'returns the original meters' do
      expect(selection.underlying_meters).to eq(meters)
    end
  end
end

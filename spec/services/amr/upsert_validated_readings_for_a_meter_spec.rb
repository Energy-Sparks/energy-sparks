require 'rails_helper'

describe Amr::UpsertValidatedReadingsForAMeter, type: :service do
  let(:dashboard_meter) { build(:dashboard_gas_meter) }

  subject(:service) { Amr::UpsertValidatedReadingsForAMeter.new(dashboard_meter) }

  describe '#perform' do
    before do
      service.perform
    end

    context 'when there are no validated readings in the database' do
      let(:active_record_meter) { create(:gas_meter) }

      context 'and the analytics returns no data' do
        it 'inserts nothing' do
          expect(AmrValidatedReading.count).to eq 0
        end
      end

      context 'and analytics returns invalid data' do
        let(:dashboard_meter) do
          build(:dashboard_gas_meter_with_validated_reading,
          reading_count: 1, actual_meter: active_record_meter, kwh_data_x48: Array.new(48, Float::NAN))
        end

        it 'does not insert that data' do
          expect(AmrValidatedReading.count).to eq 0
        end
      end

      context 'and the analytics returns valid data' do
        let(:start_date)        { Time.zone.today - 2 }
        let(:end_date)          { Time.zone.today }
        let(:expected_readings) { 3 }

        let(:kwh_data_x48)      { Array.new(48, 2.0) }
        let(:upload_datetime)   { DateTime.now.utc }

        let(:dashboard_meter)   do
          build(:dashboard_gas_meter_with_validated_reading,
          start_date: start_date,
          end_date: end_date,
          actual_meter: active_record_meter,
          kwh_data_x48: kwh_data_x48,
          upload_datetime: upload_datetime)
        end

        let(:first_reading) { active_record_meter.amr_validated_readings.order(reading_date: :asc).first }

        it 'inserts all the validated records from the analytics' do
          expect(AmrValidatedReading.count).to eq expected_readings
          expect(active_record_meter.amr_validated_readings.count).to eq expected_readings
        end

        it 'inserts all attributes' do
          expect(first_reading.reading_date).to eq start_date
          expect(first_reading.status).to eq('ORIG')
          expect(first_reading.kwh_data_x48).to eq kwh_data_x48
          expect(first_reading.one_day_kwh).to eq kwh_data_x48.sum
          expect(first_reading.substitute_date).to eq nil
          expect(first_reading.upload_datetime.utc.to_s).to eq upload_datetime.utc.to_s
        end
      end
    end

    context 'when there are validated readings in the database' do
      let(:start_date)        { Time.zone.today - 2 }
      let(:end_date)          { Time.zone.today }
      let(:expected_readings) { 3 }

      # Same values for all readings
      let(:kwh_data_x48)      { Array.new(48, 0.5) }
      let(:one_day_kwh)       { kwh_data_x48.sum }
      let(:status)            { 'ORIG' }
      let(:upload_datetime)   { DateTime.now.utc }

      let!(:active_record_meter) do
        create(:gas_meter_with_validated_reading_dates,
          start_date: start_date,
          end_date: end_date,
          kwh_data_x48: kwh_data_x48,
          one_day_kwh: one_day_kwh,
          status: status,
          substitute_date: nil,
          upload_datetime: upload_datetime
        )
      end

      let(:first_reading) { active_record_meter.amr_validated_readings.order(reading_date: :asc).first }

      context 'and the analytics has no new data' do
        # Created OneDayAMRReading will all be identical to those in database
        let(:dashboard_meter) do
          build(:dashboard_gas_meter_with_validated_reading,
            start_date: start_date,
            end_date: end_date,
            actual_meter: active_record_meter,
            kwh_data_x48: kwh_data_x48,
            status: status,
            upload_datetime: upload_datetime
          )
        end

        it 'does not update the database' do
          # confirm nothing else changed
          expect(AmrValidatedReading.count).to eq expected_readings
          expect(first_reading.reading_date).to eq start_date
          expect(first_reading.kwh_data_x48).to eq kwh_data_x48
          expect(first_reading.status).to eq status
          expect(first_reading.substitute_date).to be_nil
          expect(first_reading.upload_datetime.utc.to_s).to eq upload_datetime.utc.to_s
        end
      end

      context 'and the analytics has new readings to insert' do
        let(:expected_readings) { 4 }
        # Extra day of data from the analytics
        let(:dashboard_meter)   do
          build(:dashboard_gas_meter_with_validated_reading,
            start_date: start_date - 1,
            end_date: end_date,
            actual_meter: active_record_meter,
            kwh_data_x48: kwh_data_x48,
            status: status,
            upload_datetime: upload_datetime
          )
        end

        it 'inserts the new records' do
          expect(AmrValidatedReading.count).to eq expected_readings
          expect(active_record_meter.amr_validated_readings.count).to eq expected_readings
        end
      end

      context 'and the analytics has substituted all the data' do
        # All new fields for the same reading date
        let(:new_datetime)         { (DateTime.now - 10).utc }
        let(:new_data)             { Array.new(48, 1.5) }
        let(:new_status)           { 'GSS1' }
        let(:new_substitute_date)  { Time.zone.today - 7 }
        # force this to be very different so we can be sure we're saving right value

        let(:dashboard_meter) do
          build(:dashboard_gas_meter_with_validated_reading,
            start_date: start_date,
            end_date: end_date,
            actual_meter: active_record_meter,
            status: new_status,
            kwh_data_x48: new_data,
            substitute_date: new_substitute_date,
            upload_datetime: new_datetime
          )
        end

        it 'updates the existing records' do
          expect(AmrValidatedReading.count).to eq expected_readings
          expect(first_reading.reading_date).to eq start_date
          expect(first_reading.kwh_data_x48).to eq new_data
          expect(first_reading.status).to eq new_status
          expect(first_reading.substitute_date).to eq new_substitute_date
          expect(first_reading.upload_datetime.utc.to_s).to eq new_datetime.utc.to_s
        end
      end

      context 'and the supplier has sent new original data' do
        # Note: we're simulating supplier having sent new original data by
        # building readings for same dates, same status but different kwh values
        let(:new_datetime)     { (DateTime.now - 10).utc }
        let(:new_data)         { Array.new(48, 2.5) }

        let(:dashboard_meter) do
          build(:dashboard_gas_meter_with_validated_reading,
            start_date: start_date,
            end_date: end_date,
            actual_meter: active_record_meter,
            status: status,
            kwh_data_x48: new_data,
            upload_datetime: new_datetime
          )
        end

        let(:first_reading) { active_record_meter.amr_validated_readings.order(reading_date: :asc).first }

        it 'updates the existing records' do
          expect(AmrValidatedReading.count).to eq expected_readings
          expect(first_reading.reading_date).to eq start_date
          expect(first_reading.status).to eq status
          expect(first_reading.kwh_data_x48).to eq new_data
          expect(first_reading.upload_datetime.utc.to_s).to eq new_datetime.utc.to_s
        end
      end

      context 'and the analytics has changed just the status code' do
        let(:new_status) { 'GSS1' }
        let(:dashboard_meter) do
          build(:dashboard_gas_meter_with_validated_reading,
            start_date: start_date,
            end_date: end_date,
            actual_meter: active_record_meter,
            status: new_status,
            kwh_data_x48: kwh_data_x48,
            upload_datetime: upload_datetime
          )
        end
        let(:first_reading) { active_record_meter.amr_validated_readings.order(reading_date: :asc).first }

        it 'updates the existing records' do
          expect(AmrValidatedReading.count).to eq expected_readings
          expect(first_reading.reading_date).to eq start_date
          expect(first_reading.status).to eq new_status
          expect(first_reading.kwh_data_x48).to eq kwh_data_x48
          expect(first_reading.upload_datetime.utc.to_s).to eq upload_datetime.utc.to_s
        end
      end
    end
  end
end

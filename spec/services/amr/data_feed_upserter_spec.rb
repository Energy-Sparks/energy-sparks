require 'rails_helper'

describe Amr::DataFeedUpserter do
  subject(:service) { described_class.new(amr_data_feed_config, amr_data_feed_import_log, array_of_readings)}

  let!(:meter) { create(:electricity_meter) }
  let!(:amr_data_feed_config) { create(:amr_data_feed_config) }
  let!(:amr_data_feed_import_log) { create(:amr_data_feed_import_log, amr_data_feed_config: amr_data_feed_config)}
  let(:array_of_readings) { [] }

  def create_reading(meter, date = Time.zone.today.iso8601, readings = Array.new(48, '1.0'))
    {
      mpan_mprn: meter.mpan_mprn,
      meter_id: meter.id,
      reading_date: date,
      readings: readings,
      amr_data_feed_config_id: amr_data_feed_config.id
    }
  end

  shared_examples 'it correctly inserts when there is no saved data' do
    context 'with empty database' do
      context 'with no data to insert' do
        it 'does nothing' do
          expect { service.perform }.not_to change(AmrDataFeedReading, :count)
        end
      end

      context 'with data to insert' do
        let(:array_of_readings) do
          [create_reading(meter)]
        end

        it 'inserts new records' do
          expect { service.perform }.to change(AmrDataFeedReading, :count).by(1)
        end

        it 'adds import log' do
          service.perform
          expect(meter.amr_data_feed_readings.first.amr_data_feed_import_log).to eq(amr_data_feed_import_log)
        end

        it 'adds timestamps' do
          service.perform
          expect(meter.amr_data_feed_readings.first.created_at).not_to be_nil
          expect(meter.amr_data_feed_readings.first.updated_at).not_to be_nil
        end

        it 'updates import log with statistics' do
          service.perform
          amr_data_feed_import_log.reload
          expect(amr_data_feed_import_log.records_imported).to eq 1
          expect(amr_data_feed_import_log.records_updated).to eq 0
        end

        context 'with multiple rows' do
          let(:array_of_readings) do
            [create_reading(meter, '2024-01-01'), create_reading(meter, '2024-01-02')]
          end

          it 'inserts new records' do
            expect { service.perform }.to change(AmrDataFeedReading, :count).by(2)
            expect(AmrDataFeedReading.all.pluck(:reading_date)).to match_array(%w[2024-01-01 2024-01-02])
          end
        end
      end
    end
  end

  shared_examples 'it correctly identifies records when upserting' do
    context 'with data for different meter' do
      let!(:todays_reading) { create(:amr_data_feed_reading, reading_date: Time.zone.today.iso8601, readings: Array.new(48, '2.0')) }

      let(:array_of_readings) do
        [create_reading(meter)]
      end

      it 'inserts new records' do
        expect { service.perform }.to change(AmrDataFeedReading, :count).by(1)
        todays_reading.reload
        expect(todays_reading.readings).to eq(Array.new(48, '2.0'))
        expect(meter.amr_data_feed_readings.first.readings).to eq(Array.new(48, '1.0'))
      end

      it 'updates import log with statistics' do
        service.perform
        amr_data_feed_import_log.reload
        expect(amr_data_feed_import_log.records_imported).to eq 1
        expect(amr_data_feed_import_log.records_updated).to eq 0
      end
    end

    context 'with data for same meter but different date formats' do
      let!(:todays_reading) do
        create(:amr_data_feed_reading,
        meter: meter,
        reading_date: Time.zone.today.strftime('%d %b %Y %H:%M'),
        readings: Array.new(48, '2.0'))
      end

      let(:array_of_readings) do
        [create_reading(meter)]
      end

      it 'inserts new records' do
        expect { service.perform }.to change(AmrDataFeedReading, :count).by(1)
        todays_reading.reload
        expect(todays_reading.readings).to eq(Array.new(48, '2.0'))
        expect(AmrDataFeedReading.all.order(:updated_at).last.readings).to eq(Array.new(48, '1.0'))
      end

      it 'updates import log with statistics' do
        service.perform
        amr_data_feed_import_log.reload
        expect(amr_data_feed_import_log.records_imported).to eq 1
        expect(amr_data_feed_import_log.records_updated).to eq 0
      end
    end
  end

  shared_examples 'it updates existing readings' do
    let!(:todays_reading) { create(:amr_data_feed_reading, mpan_mprn: meter.mpan_mprn, reading_date: Time.zone.today.iso8601, readings: Array.new(48, 2.0)) }

    let(:array_of_readings) do
      [create_reading(meter)]
    end

    before do
      create(:amr_data_feed_reading, mpan_mprn: meter.mpan_mprn, reading_date: '2024-01-01', readings: Array.new(48, '2.0'))
    end

    it 'does not insert new data' do
      expect { service.perform }.not_to change(AmrDataFeedReading, :count)
    end

    it 'updates the readings' do
      service.perform
      todays_reading.reload
      expect(todays_reading.readings).to eq(Array.new(48, '1.0'))
    end

    it 'updates import log with statistics' do
      service.perform
      amr_data_feed_import_log.reload
      expect(amr_data_feed_import_log.records_imported).to eq 0
      expect(amr_data_feed_import_log.records_updated).to eq 1
    end

    it 'updates the other attributes' do
      service.perform
      todays_reading.reload
      expect(todays_reading.amr_data_feed_config).to eq(amr_data_feed_config)
      expect(todays_reading.amr_data_feed_import_log).to eq(amr_data_feed_import_log)
      expect(todays_reading.created_at).not_to be_nil
      expect(todays_reading.updated_at).not_to be_nil
    end
  end

  describe '#perform' do
    it_behaves_like 'it correctly inserts when there is no saved data'

    context 'with existing records' do
      context 'with no data to insert' do
        before do
          create(:amr_data_feed_reading, mpan_mprn: meter.mpan_mprn)
        end

        it 'does nothing' do
          expect { service.perform }.not_to change(AmrDataFeedReading, :count)
        end
      end

      context 'with data for same meter and dates' do
        it_behaves_like 'it updates existing readings'
      end

      it_behaves_like 'it correctly identifies records when upserting'
    end

    context 'with config that allows merging' do
      let!(:amr_data_feed_config) { create(:amr_data_feed_config, allow_merging: true) }

      it_behaves_like 'it correctly inserts when there is no saved data'

      context 'with existing readings' do
        context 'with no data to insert' do
          before do
            create(:amr_data_feed_reading, mpan_mprn: meter.mpan_mprn)
          end

          it 'does nothing' do
            expect { service.perform }.not_to change(AmrDataFeedReading, :count)
          end
        end

        context 'with data for same meter and dates' do
          context 'when existing and new are both full days' do
            it_behaves_like 'it updates existing readings'
          end

          context 'when the new partial readings do not overlap the existing' do
            let!(:existing) do
              create(:amr_data_feed_reading, mpan_mprn: meter.mpan_mprn, reading_date: Time.zone.today.iso8601, readings: Array.new(48) { |i| i < 2 ? '1.0' : nil })
            end

            let(:array_of_readings) do
              [create_reading(meter, Time.zone.today.iso8601, Array.new(48) { |i| i >= 2 ? '2.0' : nil })]
            end

            it 'merges the readings' do
              expect { service.perform }.not_to change(AmrDataFeedReading, :count)
              existing.reload
              expect(existing.readings).to eq(Array.new(2, '1.0') + Array.new(46, '2.0'))
            end
          end

          context 'when the new partial readings partially overlap the existing' do
            let!(:existing) do
              create(:amr_data_feed_reading, mpan_mprn: meter.mpan_mprn, reading_date: Time.zone.today.iso8601, readings: Array.new(48) { |i| i < 3 ? '1.0' : nil })
            end

            let(:array_of_readings) do
              [create_reading(meter, Time.zone.today.iso8601, Array.new(48) { |i| i >= 2 ? '2.0' : nil })]
            end

            it 'merges the readings, but overwrites the overlaps' do
              expect { service.perform }.not_to change(AmrDataFeedReading, :count)
              existing.reload
              expect(existing.readings).to eq(Array.new(2, '1.0') + Array.new(46, '2.0'))
            end
          end

          context 'with a full day of new readings' do
            let!(:existing) do
              create(:amr_data_feed_reading, mpan_mprn: meter.mpan_mprn, reading_date: Time.zone.today.iso8601, readings: Array.new(48) { |i| i < 2 ? '2.0' : nil })
            end

            let(:array_of_readings) do
              [create_reading(meter)]
            end

            it 'overwrites the existing readings' do
              expect { service.perform }.not_to change(AmrDataFeedReading, :count)
              existing.reload
              expect(existing.readings).to eq(Array.new(48, '1.0'))
            end
          end

          context 'when there are still gaps in new data' do
            let!(:existing) do
              create(:amr_data_feed_reading, mpan_mprn: meter.mpan_mprn, reading_date: Time.zone.today.iso8601, readings: Array.new(48) { |i| i < 2 ? '1.0' : nil })
            end

            let(:array_of_readings) do
              [create_reading(meter, Time.zone.today.iso8601, Array.new(48) { |i| i >= 2 && i < 10 ? '2.0' : nil })]
            end

            it 'merges the readings' do
              expect { service.perform }.not_to change(AmrDataFeedReading, :count)
              existing.reload
              expect(existing.readings).to eq(Array.new(2, '1.0') + Array.new(8, '2.0') + Array.new(38))
            end
          end
        end

        it_behaves_like 'it correctly identifies records when upserting'
      end
    end
  end
end

# frozen_string_literal: true

shared_examples 'a school week comparison ignoring estimated readings' do
  let(:amr_data) { alert.aggregate_meter.amr_data }

  describe '#enough_data' do
    before { alert.analyse(analysis_date) }

    it 'accepts two weeks of non-estimated readings' do
      expect(alert.enough_data).to eq(:enough)
    end

    { 'previous' => Date.new(2023, 10, 2), 'current' => Date.new(2023, 10, 9) }.each do |period, monday|
      context "when the #{period} week has estimated readings" do
        it 'accepts four non-estimated weekdays' do
          amr_data[monday].set_type('EST')

          expect(alert.enough_data).to eq(:enough)
        end

        it 'rejects fewer than four non-estimated weekdays' do
          amr_data[monday].set_type('EST')
          amr_data[monday + 1].set_type('EST')

          expect(alert.enough_data).to eq(:not_enough)
        end

        it 'treats missing weekdays like estimated weekdays' do
          amr_data.delete(monday)
          amr_data[monday + 1].set_type('EST')

          expect(alert.enough_data).to eq(:not_enough)
        end

        it 'does not count non-estimated weekend readings towards the minimum' do
          (monday..(monday + 4)).each { |date| amr_data[date].set_type('EST') }

          expect(alert.enough_data).to eq(:not_enough)
        end
      end
    end
  end

  describe '#analyse with estimated readings' do
    [Date.new(2023, 10, 2), Date.new(2023, 10, 9)].each do |monday|
      it "does not calculate the comparison with insufficient actual data in the week of #{monday}" do
        amr_data[monday].set_type('EST')
        amr_data[monday + 1].set_type('EST')

        alert.analyse(analysis_date)

        expect(alert.enough_data).to eq(:not_enough)
        expect(alert.current_period_kwh).to be_nil
      end
    end
  end

  describe '#meter_readings_up_to_date_enough?' do
    it 'accepts recent non-estimated readings' do
      expect(alert.meter_readings_up_to_date_enough?).to be true
    end

    context 'with estimated readings after the last non-estimated reading' do
      before do
        amr_data.each do |date, reading|
          reading.set_type('EST') if date > analysis_date - days_out_of_date
        end
      end

      context 'when the last non-estimated reading is 20 days old' do
        let(:days_out_of_date) { 20 }

        it 'accepts the readings' do
          expect(alert.meter_readings_up_to_date_enough?).to be true
        end
      end

      context 'when the last non-estimated reading is 21 days old' do
        let(:days_out_of_date) { 21 }

        it 'rejects the readings' do
          expect(alert.meter_readings_up_to_date_enough?).to be false
          expect(alert.relevance).to eq(:not_relevant)
        end
      end
    end

    context 'when all readings are estimated' do
      before { amr_data.each_value { |reading| reading.set_type('EST') } }

      it 'rejects the readings' do
        expect(alert.meter_readings_up_to_date_enough?).to be false
      end
    end
  end
end

# frozen_string_literal: true

RSpec.shared_examples 'a holiday usage alert' do
  let(:asof_date) { Date.new(2023, 12, 23) }

  include_context 'with today'

  describe '#enough_data?' do
    context 'with enough data' do
      it 'returns :enough' do
        expect(alert.enough_data).to eq(:enough)
      end
    end

    context 'when outside holiday' do
      let(:asof_date) { Date.new(2023, 12, 15) }

      it 'returns :not_enough' do
        expect(alert.enough_data).to eq(:not_enough)
      end
    end

    context 'when data doesnt cover holiday' do
      let(:amr_end_date) { Date.new(2023, 12, 10) }
      let(:asof_date) { Date.new(2023, 12, 15) }

      it 'returns :not_enough' do
        expect(alert.enough_data).to eq(:not_enough)
      end
    end
  end

  describe '#analyse' do
    before do
      alert.analyse(asof_date)
    end

    context 'when outside holiday period' do
      let(:asof_date) { Date.new(2023, 12, 15) }

      it 'is not relevant' do
        expect(alert.relevance).to eq(:never_relevant)
      end

      it 'returns default rating' do
        expect(alert.rating).to eq(10.0)
      end
    end

    context 'when 1 week into a holiday' do
      # 7 days from 16th December to 23rd December
      let(:asof_date) { Date.new(2023, 12, 22) }

      it 'calculates rating' do
        expect(alert.rating).to eq(0.0)
      end

      it 'calculates expected usage' do
        # usage_per_hh * 48 * 7 days
        expect(alert.holiday_usage_to_date_kwh).to be_within(0.001).of(3360.0)
        # flat_rate tariff * kwh above
        expect(alert.holiday_usage_to_date_£).to be_within(0.001).of(336.0)
        # carbon_intensity * kwh above
        expect(alert.holiday_usage_to_date_co2).to be_within(0.001).of(672.0)
      end

      it 'calculates expected projection' do
        # usage_per_hh * 48 * 17 days
        expect(alert.holiday_projected_usage_kwh).to be_within(0.001).of(8160.0)
        expect(alert.holiday_projected_usage_£).to be_within(0.001).of(816.0)
        expect(alert.holiday_projected_usage_co2).to be_within(0.001).of(1632.0)
      end

      context 'with a very low consumption' do
        let(:usage_per_hh)      { 0.1 }

        it 'calculates expected usage' do
          # usage_per_hh * 48 * 7 days
          expect(alert.holiday_usage_to_date_kwh).to be_within(0.001).of(33.60)
          # flat_rate tariff * kwh above
          # This is less than the £10 usage threshold
          expect(alert.holiday_usage_to_date_£).to be_within(0.001).of(3.36)
          # carbon_intensity * kwh above
          expect(alert.holiday_usage_to_date_co2).to be_within(0.001).of(6.72)
        end

        it 'assigns nil rating when usage is less than threshold' do
          expect(alert.rating).to eq(nil)
        end
      end
    end

    context 'with 2 weekend days into a holiday' do
      # 2 days from 16th December to 17th December
      let(:asof_date) { Date.new(2023, 12, 17) }

      it 'calculates rating' do
        expect(alert.rating).to eq(0.0)
      end

      it 'calculates expected usage' do
        # usage_per_hh * 48 * 2 days
        expect(alert.holiday_usage_to_date_kwh).to be_within(0.001).of(960.0)
        # flat_rate tariff * kwh above
        expect(alert.holiday_usage_to_date_£).to be_within(0.001).of(96.0)
        # carbon_intensity * kwh above
        expect(alert.holiday_usage_to_date_co2).to be_within(0.001).of(192.0)
      end

      it 'calculates expected projection' do
        # usage_per_hh * 48 * 17 days
        # confirms that weekend usage is substituted for weekday
        # when we don't have additional data
        expect(alert.holiday_projected_usage_kwh).to be_within(0.001).of(8160.0)
        expect(alert.holiday_projected_usage_£).to be_within(0.001).of(816.0)
        expect(alert.holiday_projected_usage_co2).to be_within(0.001).of(1632.0)
      end
    end
  end
end

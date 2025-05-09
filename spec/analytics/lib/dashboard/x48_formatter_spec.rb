# frozen_string_literal: true

require 'rails_helper'

describe X48Formatter do
  describe 'when no readings' do
    let(:start_date) { Date.parse('20190101') }
    let(:end_date) { start_date }
    let(:dt_to_kwh) { {} }

    it 'returns hash' do
      response = described_class.convert_dt_to_v_to_date_to_v_x48(start_date, end_date, dt_to_kwh)
      expect(response.keys).to eq(%i[readings missing_readings])
      expect(response[:readings]).to eq({})
      expect(response[:missing_readings].count).to eq(48)
    end
  end

  describe 'when partial readings' do
    let(:start_date) { Date.parse('20190101') }
    let(:end_date) { start_date }
    let(:first_time_slot) { DateTime.parse('201901010030') }
    let(:second_time_slot) { DateTime.parse('201901010100') }
    let(:last_time_slot) { DateTime.parse('201901020000') }
    let(:dt_to_kwh) { { first_time_slot => 123.0, second_time_slot => 456.0, last_time_slot => 789.0 } }

    it 'starts at 0030, ends at 0000 next day' do
      expected_x48 = Array.new(48, nil)
      expected_x48[0] = 123.0
      expected_x48[1] = 456.0
      expected_x48[47] = 789.0
      response = described_class.convert_dt_to_v_to_date_to_v_x48(start_date, end_date, dt_to_kwh, true)
      expect(response.keys).to eq(%i[readings missing_readings])
      expect(response[:readings][start_date]).to eq(expected_x48)
      expect(response[:missing_readings].count).to eq(45)
    end
  end

  describe 'when partial readings and no offset' do
    let(:start_date) { Date.parse('20190101') }
    let(:end_date) { start_date }
    let(:first_time_slot) { DateTime.parse('201901010000') }
    let(:second_time_slot) { DateTime.parse('201901010030') }
    let(:last_time_slot) { DateTime.parse('201901012330') }
    let(:dt_to_kwh) { { first_time_slot => 123.0, second_time_slot => 456.0, last_time_slot => 789.0 } }

    it 'starts at 0000, ends at 2330 same day' do
      expected_x48 = Array.new(48, nil)
      expected_x48[0] = 123.0
      expected_x48[1] = 456.0
      expected_x48[47] = 789.0
      response = described_class.convert_dt_to_v_to_date_to_v_x48(start_date, end_date, dt_to_kwh)
      expect(response.keys).to eq(%i[readings missing_readings])
      expect(response[:readings][start_date]).to eq(expected_x48)
      expect(response[:missing_readings].count).to eq(45)
    end
  end
end

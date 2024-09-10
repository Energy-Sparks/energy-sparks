# frozen_string_literal: true

require 'rails_helper'

describe CalculateAverageSchool, type: :service do
  before do
    schools = [create(:school, number_of_pupils: 1), create(:school, number_of_pupils: 2)]
    schools.each do |school|
      create(:electricity_meter_with_validated_reading_dates,
             reading: school.number_of_pupils, end_date: Date.parse('30/07/2019'), school:)
    end
  end

  describe '#calculate_school_averages' do
    it 'calculates' do
      data = described_class.perform
      expect(data.keys).to contain_exactly(:electricity, :gas)
      expect(data[:electricity].keys).to contain_exactly(:average, :benchmark, :exemplar)
      expect(data[:electricity][:average]).to eq(
        { primary: { samples: 2,
                     schoolday: { 6 => Array.new(48, 1.0), 7 => Array.new(48, 1.0) },
                     weekend: { 6 => Array.new(48, 1.0), 7 => Array.new(48, 1.0) } } }
      )
      expect(data[:gas]).to eq({ average: {}, benchmark: {}, exemplar: {} })
    end
  end
end

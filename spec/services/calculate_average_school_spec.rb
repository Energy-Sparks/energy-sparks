# frozen_string_literal: true

require 'rails_helper'

describe CalculateAverageSchool, type: :service do
  before { travel_to(Date.new(2026, 8, 1)) }

  describe '#calculate_school_averages' do
    subject(:data) { described_class.perform }

    shared_examples 'it produces the expected fuel types and benchmarks' do
      it 'calculates the expected fuel types' do
        expect(data.keys).to contain_exactly(:electricity, :gas)
      end

      it 'calculates the expected benchmarks' do
        expect(data[:electricity].keys).to contain_exactly(:average, :benchmark, :exemplar)
      end
    end

    shared_examples 'it produces the average school data for the school type' do
      let(:fuel_type) { :electricity }
      let(:school_type) { :primary }
      let(:schools) { 1 }

      it 'creates the average data' do
        month_hash = (1..12).index_with { |_k| Array.new(48, 1.0) }

        expect(data[fuel_type][:average][school_type]).to eq(
          {
            samples: schools,
            schoolday: month_hash,
            weekend: month_hash,
            holiday: {
              autumn_half_term: Array.new(48, 1.0),
              easter: Array.new(48, 1.0),
              summer: Array.new(48, 1.0),
              xmas: Array.new(48, 1.0)
            }
          }
        )
      end
    end

    context 'with only primary' do
      before do
        create(:school, :with_basic_configuration_single_meter_and_tariffs, reading: 1.0, number_of_pupils: 1)
      end

      it_behaves_like 'it produces the expected fuel types and benchmarks'
      it_behaves_like 'it produces the average school data for the school type'

      context 'with multiple schools' do
        before do
          create(:school, :with_basic_configuration_single_meter_and_tariffs, reading: 4.0, number_of_pupils: 2)
        end

        it 'correctly averages the data, scaling by pupil numbers' do
          expect(data[:electricity][:average][:primary][:holiday][:xmas]).to eq(Array.new(48, 1.5))
        end
      end

      context 'with multiple primary schools some with heat pumps' do
        before do
          create(:school,
                 :with_basic_configuration_single_meter_and_tariffs,
                 reading: 1.0,
                 number_of_pupils: 1,
                 heating_air_source_heat_pump: true)
        end

        it_behaves_like 'it produces the average school data for the school type'
        it_behaves_like 'it produces the average school data for the school type' do
          let(:school_type) { :primary_with_heat_pump }
        end
      end

      it 'calculates gas' do
        expect(data[:gas]).to eq({ average: {}, benchmark: {}, exemplar: {} })
      end
    end

    context 'with secondary' do
      before do
        create(:school, :with_basic_configuration_single_meter_and_tariffs, reading: 1.0, number_of_pupils: 1)
        create(:school, :with_basic_configuration_single_meter_and_tariffs, school_type: :secondary, reading: 1.0,
                                                                            number_of_pupils: 1)
      end

      it_behaves_like 'it produces the expected fuel types and benchmarks'
      it_behaves_like 'it produces the average school data for the school type'
      it_behaves_like 'it produces the average school data for the school type' do
        let(:school_type) { :secondary }
      end
    end

    context 'with special' do
      before do
        create(:school, :with_basic_configuration_single_meter_and_tariffs, reading: 1.0, number_of_pupils: 1)
        create(:school, :with_basic_configuration_single_meter_and_tariffs, school_type: :special, reading: 1.0,
                                                                            number_of_pupils: 1)
      end

      it_behaves_like 'it produces the expected fuel types and benchmarks'
      it_behaves_like 'it produces the average school data for the school type'
      it_behaves_like 'it produces the average school data for the school type' do
        let(:school_type) { :special }
      end
    end

    context 'with mixed primary and secondary' do
      before do
        create(:school, :with_basic_configuration_single_meter_and_tariffs, reading: 1.0, number_of_pupils: 1)
        create(:school, :with_basic_configuration_single_meter_and_tariffs, school_type: :mixed_primary_and_secondary,
                                                                            reading: 1.0, number_of_pupils: 1)
      end

      it_behaves_like 'it produces the expected fuel types and benchmarks'
      it_behaves_like 'it produces the average school data for the school type'
      it_behaves_like 'it produces the average school data for the school type' do
        let(:school_type) { :mixed_primary_and_secondary }
      end
    end
  end
end

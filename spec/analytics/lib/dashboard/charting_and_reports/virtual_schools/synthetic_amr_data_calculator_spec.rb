# frozen_string_literal: true

require 'rails_helper'

describe SyntheticAMRDataCalculator do
  let(:calculator) { described_class.new(meter_collection) }

  describe '#benchmark_amr_data' do
    subject(:synthetic_data) do
      calculator.benchmark_amr_data(meter: meter_collection.aggregated_electricity_meters, benchmark_type:)
    end

    let(:benchmark_type) { :benchmark }

    let(:school_attributes) do
      {
        school_type: :primary,
        heat_pump: false
      }
    end

    include_context 'with an aggregated meter with tariffs and school times' do
      let(:amr_start_date)  { Date.new(2024, 1, 1) }
      let(:amr_end_date)    { Date.new(2025, 12, 31) }
      let(:holidays) { build(:holidays, :with_calendar_year, year: 2025) }
      let(:extra_school_attributes) { school_attributes }
    end

    shared_examples 'it generates the expected range' do
      it { expect(synthetic_data.start_date).to eq(amr_start_date) }
      it { expect(synthetic_data.end_date).to eq(amr_end_date) }
      it { expect(synthetic_data.days_amr_data(amr_end_date).type).to eq('CAVG') }
    end

    shared_examples 'it generates expected amr data' do
      let(:benchmark_school_type) { meter_collection.school_type.to_sym }

      it 'scales holiday data by pupil numbers' do
        xmas = Schools::AverageSchoolData.raw_data[fuel_type][benchmark_type][benchmark_school_type][:holiday][:xmas]
        expect(synthetic_data.days_kwh_x48(amr_end_date)).to eq(
          AMRData.fast_multiply_x48_x_scalar(
            xmas,
            meter_collection.number_of_pupils
          )
        )
      end
    end

    context 'with electricity' do
      context 'when school type is primary' do
        let(:school_attributes) do
          {
            school_type: :primary,
            heat_pump: false
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data'
      end

      context 'when school type is primary with heat pump' do
        let(:school_attributes) do
          {
            school_type: :primary,
            heat_pump: true
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data' do
          let(:benchmark_school_type) { :primary_with_heat_pump }
        end
      end

      context 'when school type is secondary' do
        let(:school_attributes) do
          {
            school_type: :secondary,
            heat_pump: false
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data'
      end

      context 'when school type is secondary with heat pump' do
        let(:school_attributes) do
          {
            school_type: :secondary,
            heat_pump: true
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data' do
          let(:benchmark_school_type) { :secondary_with_heat_pump }
        end
      end

      context 'when school type is special' do
        let(:school_attributes) do
          {
            school_type: :special,
            heat_pump: false
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data'
      end

      context 'when school type is special with heat pump' do
        let(:school_attributes) do
          {
            school_type: :special,
            heat_pump: true
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data' do
          let(:benchmark_school_type) { :secondary_with_heat_pump }
        end
      end

      context 'when school type is middle' do
        let(:school_attributes) do
          {
            school_type: :middle,
            heat_pump: false
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data' do
          let(:benchmark_school_type) { :secondary }
        end
      end

      context 'when school type is middle with heat pump' do
        let(:school_attributes) do
          {
            school_type: :middle,
            heat_pump: true
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data' do
          let(:benchmark_school_type) { :secondary_with_heat_pump }
        end
      end

      context 'when school type is mixed primary and secondary' do
        let(:school_attributes) do
          {
            school_type: :mixed_primary_and_secondary,
            heat_pump: false
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data' do
          let(:benchmark_school_type) { :mixed_primary_and_secondary }
        end
      end

      context 'when school type is mixed primary and secondary with heat pump' do
        let(:school_attributes) do
          {
            school_type: :mixed_primary_and_secondary,
            heat_pump: true
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data' do
          let(:benchmark_school_type) { :secondary_with_heat_pump }
        end
      end

      context 'when school type is infant' do
        let(:school_attributes) do
          {
            school_type: :infant,
            heat_pump: false
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data' do
          let(:benchmark_school_type) { :primary }
        end
      end

      context 'when school type is infant with heat pump' do
        let(:school_attributes) do
          {
            school_type: :infant,
            heat_pump: true
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data' do
          let(:benchmark_school_type) { :primary_with_heat_pump }
        end
      end

      context 'when school type is junior' do
        let(:school_attributes) do
          {
            school_type: :junior,
            heat_pump: false
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data' do
          let(:benchmark_school_type) { :primary }
        end
      end

      context 'when school type is junior with heat pump' do
        let(:school_attributes) do
          {
            school_type: :junior,
            heat_pump: true
          }
        end

        it_behaves_like 'it generates the expected range'
        it_behaves_like 'it generates expected amr data' do
          let(:benchmark_school_type) { :primary_with_heat_pump }
        end
      end
    end
  end
end

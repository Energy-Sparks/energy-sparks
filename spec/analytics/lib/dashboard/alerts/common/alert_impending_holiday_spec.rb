# frozen_string_literal: true

require 'rails_helper'
require_relative '../non_estimated_readings_shared'

describe AlertImpendingHoliday do
  subject(:alert) { described_class.new(meter_collection) }

  include_context 'with short-term alert readings'

  [:electricity, :gas, nil].permutation(2) do |fuel_type, other_fuel_type|
    next if fuel_type.nil?

    context "when checking #{fuel_type} in a #{other_fuel_type ? 'dual' : 'single'}-fuel school" do
      let(:fuel_type) { fuel_type }

      if other_fuel_type
        before do
          amr_data = build(:amr_data, :with_date_range, type: other_fuel_type, start_date: amr_end_date - 364.days,
                                                        end_date: amr_end_date)
          other_meter = build(:meter, type: other_fuel_type, amr_data:, meter_collection:)
          meter_collection.set_aggregate_meter(other_fuel_type, other_meter)
        end
      end

      it_behaves_like 'an alert requiring a minimum number of non-estimated readings',
                      minimum_days: 364,
                      extra_cases: { 2 => :not_enough, 3 => :minimum_might_not_be_accurate,
                                     363 => :minimum_might_not_be_accurate }

      it_behaves_like 'an alert without a freshness limit'
    end
  end

  describe 'template variable readers' do
    let(:calculated_variables) do
      %i[holiday_short_name holiday_long_name holiday_start_date_doy meter_fuel_type_availability
         name_of_last_year_holiday]
    end

    it 'reads the corresponding instance variable for each non-calculated template variable' do
      (described_class.const_get(:TEMPLATE_VARIABLES, false).keys - calculated_variables).each do |name|
        alert.instance_variable_set("@#{name}", 123)

        expect(alert.public_send(name)).to eq(123)
      end
    end

    it 'preserves the class-defined calculated methods' do
      calculated_variables.each do |name|
        expect(alert.method(name).owner).to eq(described_class)
      end
    end
  end
end

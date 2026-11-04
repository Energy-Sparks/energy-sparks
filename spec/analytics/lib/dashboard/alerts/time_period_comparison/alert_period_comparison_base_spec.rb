# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlertPeriodComparisonBase do
  subject(:alert) { described_class.allocate }

  it 'reads template-backed variables from their instance variables' do
    described_class.dynamic_template_variables(:electricity).each_key do |name|
      next if alert.method(name).owner == described_class

      alert.instance_variable_set("@#{name}", 123)

      expect(alert.public_send(name)).to eq(123)
    end
  end

  it 'retains readers for variables not declared in the templates' do
    %i[current_holiday_temperatures current_holiday_average_temperature
       previous_holiday_temperatures previous_holiday_average_temperature
       current_period_kwhs previous_period_kwhs_unadjusted previous_period_average_kwh_unadjusted].each do |name|
      alert.instance_variable_set("@#{name}", 123)

      expect(alert.public_send(name)).to eq(123)
    end
  end

  it 'preserves calculated template methods' do
    alert.instance_variable_set(:@difference_percent, 0.1)

    expect(alert.prefix_1).to eq(I18nHelper.adjective(:up))
    expect(alert.prefix_2).to eq(I18nHelper.adjective(:increase))
  end

  it 'keeps template metadata fuel-specific' do
    expect(described_class.dynamic_template_variables(:electricity)[:current_period_kwh][:units])
      .to eq(kwh: :electricity)
    expect(described_class.dynamic_template_variables(:gas)[:current_period_kwh][:units]).to eq(kwh: :gas)
  end
end

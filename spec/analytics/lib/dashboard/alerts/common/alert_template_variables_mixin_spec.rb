# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlertTemplateVariablesMixin do
  subject(:instance) { alert_class.new }

  let(:alert_class) do
    klass = Class.new do
      def summary
        :calculated_summary
      end
    end
    klass.const_set(:TEMPLATE_VARIABLES, { usage_kwh: {}, cost_£: {}, summary: {}, chart: {} })
    klass.include(described_class)
    klass.define_method(:chart) { :calculated_chart }
    klass
  end

  it 'creates readers for template variables' do
    instance.instance_variable_set(:@usage_kwh, 123.0)
    instance.instance_variable_set(:@cost_£, 45.0)

    expect(instance.usage_kwh).to eq(123.0)
    expect(instance.public_send(:cost_£)).to eq(45.0)
  end

  it 'returns nil for an unset variable' do
    expect(instance.usage_kwh).to be_nil
  end

  it 'preserves methods defined before inclusion' do
    expect(instance.summary).to eq(:calculated_summary)
  end

  it 'preserves methods defined after inclusion' do
    expect(instance.chart).to eq(:calculated_chart)
  end
end

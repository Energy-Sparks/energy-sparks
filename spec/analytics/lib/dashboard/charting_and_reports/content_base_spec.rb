# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

class CustomAlert < ContentBase
  # Test access to instance variables
  attr_reader :a_number, :a_cost, :a_priority, :a_boolean, :a_range

  TEMPLATE_VARIABLES = {
    a_number: {
      description: 'A number',
      units: Integer
    },
    some_string: {
      description: 'A string',
      units: String
    },
    a_cost: {
      description: 'A GBP value',
      units: :£
    },
    a_range: {
      description: 'A GBP range',
      units: :£_range
    },
    a_boolean: {
      description: 'stripped',
      units: TrueClass
    },
    date: {
      description: 'mapped to native type',
      units: Date
    },
    a_table: {
      description: 'a table',
      units: :table,
      header: %w[x y],
      column_types: [String, :£]
    },
    a_chart: {
      description: 'a chart',
      units: :chart
    },
    a_priority: {
      description: 'priority',
      units: Integer,
      priority_code: 'XYZ'
    }
  }.freeze

  def initialize(vars)
    vars.each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end

  # Test calling methods dynamically
  def some_string
    'Returned via method'
  end

  # ContentBase doesn't implement this, so sub-classes must
  def self.template_variables
    { 'Custom Alert' => TEMPLATE_VARIABLES }
  end
end

describe ContentBase do
  subject(:alert) { CustomAlert.new(vars) }

  let(:vars) do
    {
      a_number: 100,
      a_cost: 50,
      a_priority: 200
    }
  end

  describe '#i18n_prefix' do
    it 'returns correct prefix' do
      expect(alert.i18n_prefix).to eq 'analytics.custom_alert'
    end
  end

  context 'when listing variables' do
    before { CustomAlert.front_end_template_variables }

    describe '#front_end_template_variables' do
      let(:variables) { CustomAlert.front_end_template_variables }

      it 'produces basic variables' do
        expect(variables).to match({
                                     'Custom Alert' => a_hash_including(
                                       a_cost: {
                                         description: 'A GBP value',
                                         units: :£
                                       }
                                     )
                                   })
      end

      it 'converts some units' do
        expect(variables).to match({
                                     'Custom Alert' => a_hash_including(
                                       a_number: {
                                         description: 'A number',
                                         units: :integer
                                       },
                                       a_priority: {
                                         description: 'priority',
                                         priority_code: 'XYZ',
                                         units: :integer
                                       },
                                       some_string: {
                                         description: 'A string',
                                         units: :string
                                       },
                                       date: {
                                         description: 'mapped to native type',
                                         units: :date
                                       }
                                     )
                                   })
      end

      it 'adds variables for ranges' do
        expect(variables).to match({
                                     'Custom Alert' => a_hash_including(
                                       a_range_low: {
                                         description: 'A GBP range low',
                                         units: :£
                                       },
                                       a_range_high: {
                                         description: 'A GBP range high',
                                         units: :£
                                       }
                                     )
                                   })
      end

      it 'strips other variables' do
        expect(variables['Custom Alert']).not_to have_key(:a_chart)
        expect(variables['Custom Alert']).not_to have_key(:a_table)
        expect(variables['Custom Alert']).not_to have_key(:stripped)
      end
    end

    describe '#priority_template_variables' do
      let(:variables) { CustomAlert.priority_template_variables }

      it 'returns only the priority variables' do
        expect(variables).to eq({
                                  a_priority: {
                                    description: 'priority',
                                    units: :integer,
                                    priority_code: 'XYZ'
                                  }
                                })
      end
    end

    describe '#front_end_template_charts' do
      let(:charts) { CustomAlert.front_end_template_charts }

      it 'returns only charts' do
        expect(charts).to eq(
          a_chart: {
            description: 'a chart',
            units: :chart
          }
        )
      end
    end

    describe '#front_end_template_tables' do
      let(:tables) { CustomAlert.front_end_template_tables }

      it 'returns only tables' do
        expect(tables).to eq(
          a_table: {
            description: 'a table',
            units: :table,
            header: %w[x y],
            column_types: [String, :£]
          }
        )
      end
    end
  end

  context 'when returning data' do
    describe '#front_end_template_data' do
      let(:variables) { alert.front_end_template_data }

      it 'returns the expected values' do
        expect(variables).to eq({
                                  a_cost: '£50',
                                  a_number: '100',
                                  a_priority: '200',
                                  some_string: 'Returned via method',
                                  a_range: '',
                                  a_range_high: nil,
                                  a_range_low: nil
                                })
      end
    end

    describe '#priority_template_data' do
      let(:variables) { alert.priority_template_data }

      it 'returns the expected values' do
        expect(variables).to eq({ a_priority: 200 })
      end
    end

    describe '#variables_for_reporting' do
      let(:variables) { alert.variables_for_reporting }

      it 'returns the expected values' do
        expect(variables).to eq({
                                  a_cost: 50,
                                  a_number: 100,
                                  a_priority: 200,
                                  some_string: 'Returned via method',
                                  a_boolean: nil,
                                  a_range: nil
                                })
      end

      context 'with a range provided' do
        let(:vars) do
          {
            a_number: 100,
            a_cost: 50,
            a_priority: 200,
            a_range: 100..200
          }
        end

        it 'returns the expected values' do
          expect(variables).to eq({
                                    a_cost: 50,
                                    a_number: 100,
                                    a_priority: 200,
                                    some_string: 'Returned via method',
                                    a_boolean: nil,
                                    a_range_low: 100,
                                    a_range_high: 200
                                  })
        end
      end
    end
  end
end

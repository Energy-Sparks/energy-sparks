# spec/inputs/tempus_dominus_date_input_spec.rb
require 'rails_helper'

RSpec.describe TempusDominusDateInput do
  let(:template) { ActionView::Base.empty }
  let(:builder)  { SimpleForm::FormBuilder.new(:contract, object, template, {}) }

  describe '#wrapper_id' do
    subject(:input) { described_class.new(builder, :start_date, nil, {}) }

    let(:object)  { OpenStruct.new(start_date: nil) }

    context 'with a non-nested form' do
      it 'preserves the original wrapper_id behaviour' do
        expect(input.wrapper_id).to eq(
          'contract_start_date_dominus'
        )
      end
    end

    context 'with a nested form' do
      # Simulate Rails nested attributes naming:
      # e.g. commercial_contract[licences_attributes][345]
      let(:builder) do
        SimpleForm::FormBuilder.new(
          'commercial_contract[licences_attributes][345]',
        object,
        template,
        {}
      )
      end

      it 'includes the nested index in the wrapper_id' do
        expect(input.wrapper_id).to eq(
          'commercial_contract_licences_attributes__345__345_start_date_dominus'
        )
      end
    end
  end
end

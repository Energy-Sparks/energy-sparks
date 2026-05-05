# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::PriceBreakdownComponent, :include_application_helper, type: :component do
  include AdvicePageHelper

  let(:price) { Commercial::Price.new(base_price: 100.0, metering_fee: 200.0, private_account_fee: 90.0) }

  before do
    render_inline described_class.new(id: 'my-price', classes: 'custom-class', price:)
  end

  it_behaves_like 'an application component' do
    let(:expected_id) { 'my-price' }
    let(:expected_classes) { 'custom-class' }
    let(:html) { page }
  end

  it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
    let(:table_id) { '#my-price-table' }
    let(:expected_header) do
      [
        ['', 'Cost']
      ]
    end
    let(:expected_rows) do
      [
        ['Base Price', format_unit(100.0, :£, true, :ks2, :text)],
        ['Metering Fee', format_unit(200.0, :£, true, :ks2, :text)],
        ['Private Account Fee', format_unit(90.0, :£, true, :ks2, :text)],
        ['Total Price', format_unit(390.0, :£, true, :ks2, :text)]
      ]
    end
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :commercial_line_item, class: 'Commercial::LineItem' do
    invoice factory: %i[commercial_invoice]
    licence factory: %i[commercial_licence]

    private_account { false }
    number_of_meters { 0 }
    base_price { 545.0 }
    metering_fee { 0.0 }
    private_account_fee { 0.0 }
  end
end

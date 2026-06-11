# frozen_string_literal: true

FactoryBot.define do
  factory :commercial_invoice, class: 'Commercial::Invoice' do
    sequence(:purchase_order_number) { |n| "PO #{n}" }

    contract factory: %i[commercial_contract]
    created_by factory: %i[user]
  end
end

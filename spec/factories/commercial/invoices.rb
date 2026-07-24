# frozen_string_literal: true

FactoryBot.define do
  factory :commercial_invoice, class: 'Commercial::Invoice' do
    sequence(:purchase_order_number) { |n| "PO #{n}" }

    contract factory: %i[commercial_contract]
    created_by factory: %i[user]

    trait :with_line_items do
      transient do
        count { 1 }
      end

      after(:build) do |invoice, evaluator|
        create_list(:commercial_line_item, evaluator.count, invoice:)
      end
    end
  end
end

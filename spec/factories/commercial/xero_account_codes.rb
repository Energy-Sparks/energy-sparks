# frozen_string_literal: true

FactoryBot.define do
  factory :commercial_xero_account_code, class: 'Commercial::XeroAccountCode' do
    sequence(:code)
    sequence(:label) { |n| "Code #{n}" }
  end
end

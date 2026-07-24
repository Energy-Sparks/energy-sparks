# frozen_string_literal: true

FactoryBot.define do
  factory :issue_meter do
    meter
    issue
  end
end

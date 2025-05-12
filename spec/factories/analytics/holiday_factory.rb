# frozen_string_literal: true

FactoryBot.define do
  factory :holiday, class: 'Holiday' do
    transient do
      type             { :school_holiday }
      sequence(:name)  { |n| "Term #{n}" }
      start_date       { Date.today.beginning_of_month }
      end_date         { Date.today.next_month.beginning_of_month }
      academic_year    { nil }
    end

    initialize_with { new(type, name, start_date, end_date, academic_year) }
  end
end

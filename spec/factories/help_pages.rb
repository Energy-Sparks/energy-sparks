# frozen_string_literal: true

FactoryBot.define do
  factory :help_page do
    title { 'MyString' }
    feature { :school_targets } # rubocop:disable RSpec/EmptyExampleGroup
  end
end

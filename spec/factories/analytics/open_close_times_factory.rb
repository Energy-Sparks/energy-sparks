# frozen_string_literal: true

FactoryBot.define do
  factory :open_close_times, class: 'OpenCloseTimes' do
    trait :from_frontend_times do
      transient do
        school_times { [] }
        community_times { [] }
        holidays { build(:holidays, :with_calendar_year) }
      end

      initialize_with do
        OpenCloseTimes.convert_frontend_times(school_times, community_times, holidays)
      end
    end
  end
end

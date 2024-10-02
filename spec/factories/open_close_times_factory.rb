# frozen_string_literal: true

FactoryBot.define do
  factory :open_close_times, class: 'OpenCloseTimes' do
    trait :from_frontend_times do
      transient do
        school_times { [] }
        community_times { [] }
        holidays { build(:holidays, :with_calendar_year) }
      end

      # Equivalent to OpenCloseTimes.convert_frontend_times allows the object
      # to be created with simpler data structure
      initialize_with do
        st = OpenCloseTimes.convert_frontend_time(school_times)
        ct = OpenCloseTimes.convert_frontend_time(community_times)
        OpenCloseTimes.create_open_close_times({ open_close_times: st + ct }, holidays)
      end
    end
  end
end

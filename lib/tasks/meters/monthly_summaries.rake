# frozen_string_literal: true

namespace :meters do
  desc 'Create and update meter monthly summaries'
  task monthly_summaries: :environment do |_t, _args|
    School.process_data.order(:name).each do |school|
      puts school.slug
      MeterMonthlySummary.create_or_update_from_school(school, AggregateSchoolService.new(school).meter_collection)
    end
  end
end

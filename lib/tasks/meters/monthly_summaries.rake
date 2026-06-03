# frozen_string_literal: true

namespace :meters do
  desc 'Create and update meter monthly summaries'
  task monthly_summaries: :environment do |_t, _args|
    School.process_data.order(:name).each do |school|
      puts school.slug
      service = AggregateSchoolService.new(school)
      MeterMonthlySummary.create_or_update_from_school(school, service.meter_collection) if service.in_cache?
    end
  end
end

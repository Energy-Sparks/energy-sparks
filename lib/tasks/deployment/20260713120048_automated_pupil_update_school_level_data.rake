# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: automated_pupil_update_school_level_data'
  task automated_pupil_update_school_level_data: :environment do
    puts "Running deploy task 'automated_pupil_update_school_level_data'"

    SchoolMeterAttribute.floor_area_pupil_numbers
                        .where("meter_types = '[]'::jsonb")
                        .update_all(meter_types: ['school_level_data']) # rubocop:disable Rails/SkipsModelValidations

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

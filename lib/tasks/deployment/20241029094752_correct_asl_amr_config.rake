# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: correct_asl_amr_config'
  task correct_asl_amr_config: :environment do
    puts "Running deploy task 'correct_asl_amr_config'"

    config = AmrDataFeedConfig.find_by(identifier: 'asl-centrica-solar')
    times = (0..23).flat_map { |h| %w[00 30].freeze.map { |m| "#{h.to_s.rjust(2, '0')}#{m}" } }
    config.update!(
      header_example: 'reference,meter,time,total_import,total_export,' \
                      "#{config['reading_fields'].zip(times.map { |t| "export#{t}" }).join ','}"
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

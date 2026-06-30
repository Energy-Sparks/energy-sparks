# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: create_tem_config'
  task create_tem_config: :environment do
    puts "Running deploy task 'create_tem_config'"

    attributes = {
      description: 'Tem',
      notes: '',
      number_of_header_rows: 2,
      mpan_mprn_field: '', # first column, header over 2 rows but we use first for unique names
      reading_date_field: 'Settlement Period',
      date_format: '%Y-%m-%d',
      header_example: ',Settlement Period,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,' \
                      '29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48',
      reading_fields: '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,' \
                      '35,36,37,38,39,40,41,42,43,44,45,46,47,48'.split(',')
    }
    AmrDataFeedConfig.find_or_initialize_by(identifier: 'tem').tap do |config|
      config.assign_attributes(attributes)
      config.save!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

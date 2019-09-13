namespace :after_party do
  desc 'Deployment task: set_up_long_furlong'
  task set_up_long_furlong: :environment do
    puts "Running deploy task 'set_up_long_furlong'"

    # Put your task implementation HERE.
    # Table name: low_carbon_hub_installations
#
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  information             :json
#  message_for_no_contacts :boolean          default(TRUE)
#  rbee_meter_id           :integer
#  school_id               :bigint(8)        not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_low_carbon_hub_installations_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

    long_furlong = School.find_by((name: 'Long Furlong Primary School')

    installation = LowCarbonHubInstallation.create(school: long_furlong, rbee_meter_id: 216057958)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

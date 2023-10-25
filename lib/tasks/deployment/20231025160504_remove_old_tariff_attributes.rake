namespace :after_party do
  desc 'Deployment task: remove_old_tariff_attributes'
  task remove_old_tariff_attributes: :environment do
    puts "Running deploy task 'remove_old_tariff_attributes'"

    #Remove the old style tariffs stored as meter attributes
    TARIFF_ATTRIBUTE_TYPES = %w[indicative_standing_charge accounting_tariff accounting_tariff_differential economic_tariff economic_tariff_change_over_time tariff].freeze

    GlobalMeterAttribute.where(attribute_type: TARIFF_ATTRIBUTE_TYPES).delete_all
    SchoolGroupMeterAttribute.where(attribute_type: TARIFF_ATTRIBUTE_TYPES).delete_all
    SchoolMeterAttribute.where(attribute_type: TARIFF_ATTRIBUTE_TYPES).delete_all
    MeterAttribute.where(attribute_type: TARIFF_ATTRIBUTE_TYPES).delete_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

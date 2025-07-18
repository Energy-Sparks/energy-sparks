namespace :after_party do
  desc 'Deployment task: update_solar_overrides'
  task update_solar_overrides: :environment do
    puts "Running deploy task 'update_solar_overrides'"

    admin = User.find(947) # me

    MeterAttribute.active.where(attribute_type: 'solar_pv_override').find_each do |attribute|
      # for backwards compatibility with old behaviour all options need to be on
      unless attribute.input_data['override_generation'] == '1' &&
             attribute.input_data['override_export'] == '1' &&
             attribute.input_data['override_self_consume'] == '1'

        backwards_compatible_config = attribute.input_data.merge(
          'override_generation' => '1',
          'override_export' => '1',
          'override_self_consume' => '1'
        )

        attribute_manager = Meters::MeterAttributeManager.new(attribute.meter.school)

        attribute_manager.update!(
          attribute.id,
          backwards_compatible_config,
          'Made config compatible with code before bug fix. See history for original config/reason',
          admin
        )
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

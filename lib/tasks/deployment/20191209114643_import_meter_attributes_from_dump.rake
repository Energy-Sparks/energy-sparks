namespace :after_party do
  desc 'Deployment task: import_meter_attributes_from_dump'
  task import_meter_attributes_from_dump: :environment do
    puts "Running deploy task 'import_meter_attributes_from_dump'"

    db_meter_attributes = YAML.load_file('etc/meter_attributes-db.yml')

    db_meter_attributes[:meter_attributes].each do |attribute|
      MeterAttribute.create!(
        input_data: attribute[:input_data],
        attribute_type: attribute[:attribute_type],
        reason: attribute[:reason],
        meter_id: attribute[:meter_id]
      )
    end

    db_meter_attributes[:school_attributes].each do |attribute|
      SchoolMeterAttribute.create!(
        input_data: attribute[:input_data],
        attribute_type: attribute[:attribute_type],
        meter_type: attribute[:meter_type],
        reason: attribute[:reason],
        school_id: attribute[:school_id]
      )
    end

    db_meter_attributes[:school_group_attributes].each do |attribute|
      SchoolGroupMeterAttribute.create!(
        input_data: attribute[:input_data],
        attribute_type: attribute[:attribute_type],
        meter_type: attribute[:meter_type],
        reason: attribute[:reason],
        school_group_id: attribute[:school_group_id]
      )
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

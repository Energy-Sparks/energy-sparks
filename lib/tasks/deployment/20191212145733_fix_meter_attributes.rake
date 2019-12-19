namespace :after_party do
  desc 'Deployment task: fix_meter_attributes'
  task fix_meter_attributes: :environment do
    puts "Running deploy task 'fix_meter_attributes'"

    hs_meter = Meter.find_by!(mpan_mprn: '2200013680374')
    hs_meter.meter_attributes.first.update!(
      input_data: {
        start_date: '07/11/2018',
        kwp: '30.0',
        orientation: '0',
        tilt: '30',
        shading: '0',
        fit_£_per_kwh: '0.05',
      }
    )
    map_meter = Meter.find_by!(mpan_mprn: '1712485592509')
    map_meter.meter_attributes.first.update!(
      input_data: {
        start_date: '01/01/2010',
        end_date: '01/01/2025',
        power_kw: '144',
        charge_start_time: {hour: '22', minutes: '0'},
        charge_end_time: {hour: '7', minutes: '0'}
      }
    )

    mun_meter = Meter.find_by!(mpan_mprn: '9091095306')
    mun_meter.meter_attributes.find_by!(attribute_type: 'meter_corrections_set_missing_data_to_zero').update!(
      input_data: {
        start_date: '12/07/2016',
        end_date: '16/09/2016'
      }
    )

    SchoolMeterAttribute.where(attribute_type: 'storage_heater_aggreated').update_all(attribute_type: 'storage_heater_aggregated')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

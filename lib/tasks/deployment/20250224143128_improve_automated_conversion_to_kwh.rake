namespace :after_party do
  desc 'Deployment task: improve_automated_conversion_to_kwh'
  task improve_automated_conversion_to_kwh: :environment do
    puts "Running deploy task 'improve_automated_conversion_to_kwh'"

    AmrDataFeedConfig.find_by!(identifier: 'my-sefe-portal-new').update!(convert_to_kwh: :meter)

    meters = {
      9117991110 => 'm3',
      4007001508 => 'm3',
      13172107 => 'ft3',
      9143364204 => 'm3',
      9182091102 => 'm3',
      9313359409 => 'm3',
      15357410 => 'm3',
      8813288305 => 'hcf',
      9153565310 => 'm3',
      14597201 => 'm3',
      14598304 => 'm3',
      8816196506 => 'm3',
      8816197508 => 'm3',
      8818607702 => 'm3',
      8816197306 => 'm3',
      13589006 => 'm3',
      3084426903 => 'm3',
      7715002401 => 'm3',
      7715002502 => 'm3',
      9343708808 => 'm3',
      11374502 => 'm3',
      13552600 => 'hcf',
      15989504 => 'm3',
      9345714802 => 'm3',
      9348279208 => 'm3',
      8843104904 => 'm3',
      2330604 => 'hcf',
      2330705 => 'm3',
      2330907 => 'hcf',
      9347382600 => 'm3',
      9347382701 => 'm3',
      16886510 => 'hcf',
      1833231309 => 'm3',
      8756703 => 'm3',
      8838200 => 'm3',
      8725905 => 'm3',
      9392335203 => 'm3',
      7915400 => 'm3',
      9297770004 => 'm3',
      9346160004 => 'm3',
      9194424602 => 'm3'
    }
    today = Time.current.to_date
    meters.each do |mpan_mprn, gas_unit|
      puts mpan_mprn
      meter = Meter.find_by(mpan_mprn:)
      next if meter.nil?

      meter.update!(gas_unit:)
      meter.meter_attributes.where(attribute_type: 'meter_corrections_rescale_amr_data',
                                   replaced_by_id: nil, deleted_by_id: nil).find_each do |rescale_attribute|
        end_date = rescale_attribute.input_data['end_date']
        if end_date.nil? || Date.strptime(end_date, '%d/%m/%Y') > today
          puts end_date
          rescale_attribute.update!(input_data: rescale_attribute.input_data.merge(end_date: today.strftime('%d/%m/%Y')))
        end
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

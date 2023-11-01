namespace :after_party do
  desc 'Deployment task: new_tgp_manual_hh_config'
  task new_tgp_manual_hh_config: :environment do
    puts "Running deploy task 'new_tgp_manual_hh_config'"

    config = {}
    config['description'] = "TGP HH Manual"
    config['identifier'] = 'tgp-hh-manual'
    config['number_of_header_rows'] = 1
    config['header_example'] = "MPAN,@Meter/ @GSP / @NBP,Date,Sum HH Consumption (for the day),Actual or Estimate,Measurement Quantity ID,Consumption(KWh) HH1,Consumption(KWh) HH2,Consumption(KWh) HH3,Consumption(KWh) HH4,Consumption(KWh) HH5,Consumption(KWh) HH6,Consumption(KWh) HH7,Consumption(KWh) HH8,Consumption(KWh) HH9,Consumption(KWh) HH10,Consumption(KWh) HH11,Consumption(KWh) HH12,Consumption(KWh) HH13,Consumption(KWh) HH14,Consumption(KWh) HH15,Consumption(KWh) HH16,Consumption(KWh) HH17,Consumption(KWh) HH18,Consumption(KWh) HH19,Consumption(KWh) HH20,Consumption(KWh) HH21,Consumption(KWh) HH22,Consumption(KWh) HH23,Consumption(KWh) HH24,Consumption(KWh) HH25,Consumption(KWh) HH26,Consumption(KWh) HH27,Consumption(KWh) HH28,Consumption(KWh) HH29,Consumption(KWh) HH30,Consumption(KWh) HH31,Consumption(KWh) HH32,Consumption(KWh) HH33,Consumption(KWh) HH34,Consumption(KWh) HH35,Consumption(KWh) HH36,Consumption(KWh) HH37,Consumption(KWh) HH38,Consumption(KWh) HH39,Consumption(KWh) HH40,Consumption(KWh) HH41,Consumption(KWh) HH42,Consumption(KWh) HH43,Consumption(KWh) HH44,Consumption(KWh) HH45,Consumption(KWh) HH46,Consumption(KWh) HH47,Consumption(KWh) HH48,Consumption(KWh) HH49,Consumption(KWh) HH50"
    config['date_format'] = "%d/%m/%Y" # e.g. 16/10/2023
    config['mpan_mprn_field'] = 'MPAN'
    config['reading_date_field'] = 'Date'
    config['reading_fields'] = "Consumption(KWh) HH1,Consumption(KWh) HH2,Consumption(KWh) HH3,Consumption(KWh) HH4,Consumption(KWh) HH5,Consumption(KWh) HH6,Consumption(KWh) HH7,Consumption(KWh) HH8,Consumption(KWh) HH9,Consumption(KWh) HH10,Consumption(KWh) HH11,Consumption(KWh) HH12,Consumption(KWh) HH13,Consumption(KWh) HH14,Consumption(KWh) HH15,Consumption(KWh) HH16,Consumption(KWh) HH17,Consumption(KWh) HH18,Consumption(KWh) HH19,Consumption(KWh) HH20,Consumption(KWh) HH21,Consumption(KWh) HH22,Consumption(KWh) HH23,Consumption(KWh) HH24,Consumption(KWh) HH25,Consumption(KWh) HH26,Consumption(KWh) HH27,Consumption(KWh) HH28,Consumption(KWh) HH29,Consumption(KWh) HH30,Consumption(KWh) HH31,Consumption(KWh) HH32,Consumption(KWh) HH33,Consumption(KWh) HH34,Consumption(KWh) HH35,Consumption(KWh) HH36,Consumption(KWh) HH37,Consumption(KWh) HH38,Consumption(KWh) HH39,Consumption(KWh) HH40,Consumption(KWh) HH41,Consumption(KWh) HH42,Consumption(KWh) HH43,Consumption(KWh) HH44,Consumption(KWh) HH45,Consumption(KWh) HH46,Consumption(KWh) HH47,Consumption(KWh) HH48".split(",")

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

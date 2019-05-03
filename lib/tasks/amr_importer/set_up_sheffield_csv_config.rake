namespace :amr_sheffield do
  desc "Import data from csv"
  task create_config: [:environment] do
    puts "Make sure Sheffield csv config is set up"
    puts DateTime.now.utc

    AmrDataFeedConfig.where(
      description: 'Sheffield',
      s3_folder: 'sheffield',
      s3_archive_folder: 'archive-sheffield',
      local_bucket_path: 'tmp/amr_files_bucket/banes',
      access_type: 'Email',
      date_format: "%d/%m/%Y",
      mpan_mprn_field: 'MPAN',
      reading_date_field: 'ConsumptionDate',
      reading_fields:   "kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48".split(','),
      meter_description_field: 'siteRef',
      header_example: "siteRef,MPAN,ConsumptionDate,kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48,kVArh_1,kVArh_2,kVArh_3,kVArh_4,kVArh_5,kVArh_6,kVArh_7,kVArh_8,kVArh_9,kVArh_10,kVArh_11,kVArh_12,kVArh_13,kVArh_14,kVArh_15,kVArh_16,kVArh_17,kVArh_18,kVArh_19,kVArh_20,kVArh_21,kVArh_22,kVArh_23,kVArh_24,kVArh_25,kVArh_26,kVArh_27,kVArh_28,kVArh_29,kVArh_30,kVArh_31,kVArh_32,kVArh_33,kVArh_34,kVArh_35,kVArh_36,kVArh_37,kVArh_38,kVArh_39,kVArh_40,kVArh_41,kVArh_42,kVArh_43,kVArh_44,kVArh_45,kVArh_46,kVArh_47,kVArh_48"
    ).first_or_create

    puts DateTime.now.utc
    puts "Sheffield csv config is set up"
  end
end

require 'rails_helper'

describe AmrUploadedReading, type: :system do

  let!(:admin)              { create(:admin) }

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Admin'
    click_on 'AMR Data feed configuration'
  end

  describe 'normal file format' do

    let!(:config)             { create(:amr_data_feed_config) }

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'AMR Data feed configuration'
      click_on config.description
      click_on 'Upload file'
    end

    it 'can upload a file' do
      attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/banes-example-file.csv')
      expect { click_on 'Preview' }.to change { AmrUploadedReading.count }.by 1

      expect(AmrUploadedReading.count).to be 1
      expect(AmrUploadedReading.first.imported).to be false

      expect(page).to_not have_content('We have identified a problem')
      expect(page).to have_content('First ten rows')
      expect(page).to have_content('2200012767323')
      expect(page).to have_content('2200012030374')
      expect(page).to have_content('2200040922992')

      expect { click_on "I'm happy, insert this data" }.to change { AmrDataFeedReading.count }.by(5).and change { AmrDataFeedImportLog.count }.by(1)

      expect(AmrUploadedReading.count).to be 1
      expect(AmrUploadedReading.first.imported).to be true
    end

    it 'produces an error message when an invalid CSV file is uploaded' do
      attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/not_a_csv.csv')
      expect { click_on 'Preview' }.to_not change { AmrUploadedReading.count }

      expect(AmrUploadedReading.count).to be 0

      expect(page).to have_content('CSV error:')
    end


    it 'is helpful if a very different format file is loaded' do
      attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/example-sheffield-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::ERROR_UNABLE_TO_PARSE_FILE)
    end

    it 'is helpful if a dodgy date format file is loaded' do
      attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/banes-bad-example-date-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::ERROR_UNABLE_TO_PARSE_FILE)
    end

    it 'is helpful if a single dodgy date format is in the file loaded' do
      attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/banes-bad-example-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_BAD_DATE_FORMAT)
    end

    it 'is helpful if a dodgy mpan format file is loaded' do
      attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/banes-bad-example-missing-mpan-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_MISSING_MPAN_MPRN)
    end

    it 'is helpful if a reading is missing' do
      attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/banes-bad-example-missing-data-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_MISSING_READINGS)
    end

  end

  describe 'bad sheffield file' do
    let!(:config)             { create(:amr_data_feed_config,
                                          date_format: "%d/%m/%Y",
                                          mpan_mprn_field: "MPAN",
                                          reading_date_field: "ConsumptionDate",
                                          reading_fields: ["kWh_1", "kWh_2", "kWh_3", "kWh_4", "kWh_5", "kWh_6", "kWh_7", "kWh_8", "kWh_9", "kWh_10", "kWh_11", "kWh_12", "kWh_13", "kWh_14", "kWh_15", "kWh_16", "kWh_17", "kWh_18", "kWh_19", "kWh_20", "kWh_21", "kWh_22", "kWh_23", "kWh_24", "kWh_25", "kWh_26", "kWh_27", "kWh_28", "kWh_29", "kWh_30", "kWh_31", "kWh_32", "kWh_33", "kWh_34", "kWh_35", "kWh_36", "kWh_37", "kWh_38", "kWh_39", "kWh_40", "kWh_41", "kWh_42", "kWh_43", "kWh_44", "kWh_45", "kWh_46", "kWh_47", "kWh_48"],
                                          column_separator: ",",
                                          header_example: "siteRef,MPAN,ConsumptionDate,kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48,kVArh_1,kVArh_2,kVArh_3,kVArh_4,kVArh_5,kVArh_6,kVArh_7,kVArh_8,kVArh_9,kVArh_10,kVArh_11,kVArh_12,kVArh_13,kVArh_14,kVArh_15,kVArh_16,kVArh_17,kVArh_18,kVArh_19,kVArh_20,kVArh_21,kVArh_22,kVArh_23,kVArh_24,kVArh_25,kVArh_26,kVArh_27,kVArh_28,kVArh_29,kVArh_30,kVArh_31,kVArh_32,kVArh_33,kVArh_34,kVArh_35,kVArh_36,kVArh_37,kVArh_38,kVArh_39,kVArh_40,kVArh_41,kVArh_42,kVArh_43,kVArh_44,kVArh_45,kVArh_46,kVArh_47,kVArh_48",
                                          number_of_header_rows: 1 ) }

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'AMR Data feed configuration'
      click_on config.description
      click_on 'Upload file'
    end

    it 'handles a wrong file format' do
      attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/example-bad-sheffield-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_MISSING_READINGS)
    end

    it 'handles a wrong file format' do
      attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/example-bad-sheffield-proper-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_READING_DATE_MISSING)
    end
  end

  describe 'with row per reading' do

    let!(:config)             { create(:amr_data_feed_config,
                                          date_format: "%Y-%m-%d",
                                          mpan_mprn_field: "MPR",
                                          reading_date_field: "ReadDatetime",
                                          reading_fields: ["kWh"],
                                          column_separator: ",",
                                          header_example: "MPR,ReadDatetime,kWh,ReadType",
                                          row_per_reading: true,
                                          number_of_header_rows: 2 ) }

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'AMR Data feed configuration'
      click_on config.description
      click_on 'Upload file'
    end

    it 'handles a correct file format' do
      attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/example-highlands-file.csv')
      expect { click_on 'Preview' }.to change { AmrUploadedReading.count }.by 1

      expect(AmrUploadedReading.count).to be 1
      expect(AmrUploadedReading.first.imported).to be false

      expect(page).to_not have_content('We have identified a problem')
      expect(page).to have_content('First ten rows')
      expect(page).to have_content('1712423842469')

      expect { click_on "I'm happy, insert this data" }.to change { AmrDataFeedReading.count }.by(1).and change { AmrDataFeedImportLog.count }.by(1)

      expect(AmrUploadedReading.count).to be 1
      expect(AmrUploadedReading.first.imported).to be true
    end

    it 'handles a wrong file format' do
      attach_file('amr_uploaded_reading[csv_file]', 'spec/fixtures/amr_upload_csv_files/example-sheffield-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::ERROR_UNABLE_TO_PARSE_FILE)
    end
  end
end

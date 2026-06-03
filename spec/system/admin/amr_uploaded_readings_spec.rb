require 'rails_helper'

describe AmrUploadedReading, type: :system do
  let!(:admin) { create(:admin) }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Admin'
  end

  describe 'viewing configuration summary' do
    before do
      config
      click_on 'AMR Data feed configuration'
      within '#configuration-overview' do
        click_on 'Upload'
      end
    end

    context 'with row per day config' do
      let!(:config) { create(:amr_data_feed_config, row_per_reading: false, number_of_header_rows: 1) }

      it 'explains this to user' do
        expect(page).to have_content('One row per day, with all half-hourly periods in columns')
      end

      it 'says how many header rows' do
        expect(page).to have_content('1 header rows')
      end

      context 'with no header rows' do
        let!(:config) { create(:amr_data_feed_config, row_per_reading: false, number_of_header_rows: 0) }

        it 'says there are no header rows' do
          expect(page).to have_content('No header row')
        end
      end

      it 'explains the MPAN field' do
        expect(page).to have_content('The MPAN/MPRN to be in a column labelled ' + config.mpan_mprn_field)
      end

      it 'explains the date field' do
        expect(page).to have_content('The reading date to be in a column labelled ' + config.reading_date_field)
      end

      it 'explains the reading fields' do
        expect(page).to have_content('Reading fields to be in columns labelled')
      end

      context 'with a serial number config' do
        let!(:config) { create(:amr_data_feed_config, row_per_reading: false, msn_field: 'Serial', lookup_by_serial_number: true) }

        it 'explains the serial number field' do
          expect(page).to have_content('The Meter Serial Numbers in a column labelled ' + config.msn_field)
        end
      end
    end

    context 'with row per reading config' do
      let!(:config) { create(:amr_data_feed_config, :with_reading_time_field) }

      it 'explains this to user' do
        expect(page).to have_content('One row per half hour reading')
      end

      it 'explains the date field' do
        expect(page).to have_content('The reading date to be in a column labelled ' + config.reading_date_field)
      end

      it 'explains the reading field column' do
        expect(page).to have_content('A reading field column labelled ' + config.reading_fields.first)
      end

      context 'with a positional index' do
        let!(:config) { create(:amr_data_feed_config, :with_positional_index, period_field: 'SettlementTime') }

        it 'explains the index column' do
          expect(page).to have_content('A numbered half-hourly period in a column labelled SettlementTime, e.g. 1, 2, 3, 4')
        end
      end

      context 'with a separate reading time column' do
        let!(:config) { create(:amr_data_feed_config, :with_reading_time_field, reading_time_field: 'ReadingTime') }

        it 'explains the reading time column' do
          expect(page).to have_content('The reading times to specified in a separate column labelled ReadingTime')
          expect(page).to have_content('The separate reading times to be formatted like this')
        end
      end
    end

    context 'with delayed reading config' do
      let!(:config) { create(:amr_data_feed_config, delayed_reading: true, number_of_header_rows: 1) }

      it 'explains this to user' do
        expect(page).to have_content('this configuration will adjust the dates in the uploaded file backwards by 1 day')
      end
    end
  end

  describe 'normal file format' do
    let!(:config) do
      create(:amr_data_feed_config,
        description: 'BANES',
        mpan_mprn_field: 'M1_Code1',
        reading_date_field: 'Date',
        date_format: '%b %e %Y %I:%M%p',
        number_of_header_rows: 1,
        provider_id_field: 'ID',
        total_field: 'Total',
        meter_description_field: 'Location',
        postcode_field: 'PostCode',
        units_field: 'Units',
        header_example: 'ID,Date,Location,Type,PostCode,Units,Total Units,[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00],M1_Code1,M1_Code2',
        reading_fields: '[00:30],[01:00],[01:30],[02:00],[02:30],[03:00],[03:30],[04:00],[04:30],[05:00],[05:30],[06:00],[06:30],[07:00],[07:30],[08:00],[08:30],[09:00],[09:30],[10:00],[10:30],[11:00],[11:30],[12:00],[12:30],[13:00],[13:30],[14:00],[14:30],[15:00],[15:30],[16:00],[16:30],[17:00],[17:30],[18:00],[18:30],[19:00],[19:30],[20:00],[20:30],[21:00],[21:30],[22:00],[22:30],[23:00],[23:30],[24:00]'.split(',')
      )
    end

    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'AMR Data feed configuration'
      within '#configuration-overview' do
        click_on config.description
      end
      click_on 'Upload file'
    end

    %w(.csv .xlsx .xls).each do |ext|
      context "previewing a valid #{ext} file" do
        before do
          attach_file('amr_uploaded_reading[data_file]', "spec/fixtures/amr_upload_data_files/banes-example-file#{ext}")
          expect { click_on 'Preview' }.to change(AmrUploadedReading, :count).by 1
        end

        it { expect(AmrUploadedReading.count).to be 1 }
        it { expect(AmrUploadedReading.first.imported).to be false }
        it { expect(page).not_to have_content('We have identified a problem') }
        it { expect(page).to have_content('Data preview') }
        it { expect(page).to have_content('2200012767323') }
        it { expect(page).to have_content('2200012030374') }
        it { expect(page).to have_content('2200040922992') }

        context 'and uploading with the new loader' do
          before do
            expect { click_on 'Insert this data' }.to change(ManualDataLoadRun, :count).by(1)
          end

          it { expect(page).to have_content('Processing') }
          it { expect(page).not_to have_link('Upload another file') }

          context 'when complete' do
            before do
              expect_any_instance_of(ManualDataLoadRun).to receive(:complete?).at_least(:once).and_return true
              visit current_path # force / speed up page reload (that would usually happen after 5 secs anyway)
            end

            it { expect(page).not_to have_content('Processing') }

            it 'has a link to upload another file' do
              expect(page).to have_link('Upload another file')
            end

            context 'and clicking link' do
              before { click_link 'Upload another file' }

              it 'displays the manual upload page for the same configuration' do
                expect(page).to have_current_path(new_admin_amr_data_feed_config_amr_uploaded_reading_path(config))
              end
            end
          end
        end
      end
    end

    it 'produces an error message when an invalid CSV file is uploaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/not_a_csv.csv')
      expect { click_on 'Preview' }.not_to(change(AmrUploadedReading, :count))

      expect(AmrUploadedReading.count).to be 0

      expect(page).to have_content('Error:')
    end

    it 'produces an error message when an invalid xlsx file is uploaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/not_a_xlsx.xlsx')
      expect { click_on 'Preview' }.not_to(change(AmrUploadedReading, :count))

      expect(AmrUploadedReading.count).to be 0

      expect(page).to have_content('Error:')
    end

    it 'produces an error message when translator raise error' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/not_a_csv.csv')
      expect_any_instance_of(Amr::DataFileToAmrReadingData).to receive(:perform).and_raise(Amr::DataFeedException.new('bad file'))

      click_on 'Preview'

      expect(AmrUploadedReading.count).to be 0
      expect(page).to have_content('Error:')
      expect(page).to have_content('bad file')
    end


    it 'is helpful if a very different format file is loaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/example-sheffield-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::ERROR_NO_VALID_READINGS)
    end

    it 'is helpful if a dodgy date format file is loaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/banes-bad-example-date-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::ERROR_NO_VALID_READINGS)
    end

    it 'is helpful if a single dodgy date format is in the file loaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/banes-bad-example-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_BAD_DATE_FORMAT)
    end

    it 'is helpful if a dodgy mpan format file is loaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/banes-bad-example-missing-and-invalid-mpan-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_MISSING_MPAN_MPRN)
    end

    it 'is helpful if a invalid mpan format file is loaded' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/banes-bad-example-missing-and-invalid-mpan-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_INVALID_NON_NUMERIC_MPAN_MPRN)
    end

    it 'is helpful if a reading is missing' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/banes-bad-example-missing-data-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_MISSING_READINGS)
    end
  end

  describe 'bad sheffield file' do
    let!(:config) do
      create(:amr_data_feed_config,
                                          date_format: '%d/%m/%Y',
                                          mpan_mprn_field: 'MPAN',
                                          reading_date_field: 'ConsumptionDate',
                                          reading_fields: %w[kWh_1 kWh_2 kWh_3 kWh_4 kWh_5 kWh_6 kWh_7 kWh_8 kWh_9 kWh_10 kWh_11 kWh_12 kWh_13 kWh_14 kWh_15 kWh_16 kWh_17 kWh_18 kWh_19 kWh_20 kWh_21 kWh_22 kWh_23 kWh_24 kWh_25 kWh_26 kWh_27 kWh_28 kWh_29 kWh_30 kWh_31 kWh_32 kWh_33 kWh_34 kWh_35 kWh_36 kWh_37 kWh_38 kWh_39 kWh_40 kWh_41 kWh_42 kWh_43 kWh_44 kWh_45 kWh_46 kWh_47 kWh_48],
                                          column_separator: ',',
                                          header_example: 'siteRef,MPAN,ConsumptionDate,kWh_1,kWh_2,kWh_3,kWh_4,kWh_5,kWh_6,kWh_7,kWh_8,kWh_9,kWh_10,kWh_11,kWh_12,kWh_13,kWh_14,kWh_15,kWh_16,kWh_17,kWh_18,kWh_19,kWh_20,kWh_21,kWh_22,kWh_23,kWh_24,kWh_25,kWh_26,kWh_27,kWh_28,kWh_29,kWh_30,kWh_31,kWh_32,kWh_33,kWh_34,kWh_35,kWh_36,kWh_37,kWh_38,kWh_39,kWh_40,kWh_41,kWh_42,kWh_43,kWh_44,kWh_45,kWh_46,kWh_47,kWh_48,kVArh_1,kVArh_2,kVArh_3,kVArh_4,kVArh_5,kVArh_6,kVArh_7,kVArh_8,kVArh_9,kVArh_10,kVArh_11,kVArh_12,kVArh_13,kVArh_14,kVArh_15,kVArh_16,kVArh_17,kVArh_18,kVArh_19,kVArh_20,kVArh_21,kVArh_22,kVArh_23,kVArh_24,kVArh_25,kVArh_26,kVArh_27,kVArh_28,kVArh_29,kVArh_30,kVArh_31,kVArh_32,kVArh_33,kVArh_34,kVArh_35,kVArh_36,kVArh_37,kVArh_38,kVArh_39,kVArh_40,kVArh_41,kVArh_42,kVArh_43,kVArh_44,kVArh_45,kVArh_46,kVArh_47,kVArh_48',
                                          number_of_header_rows: 1)
    end

    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'AMR Data feed configuration'
      within '#configuration-overview' do
        click_on config.description
      end
      click_on 'Upload file'
    end

    it 'handles a wrong file format' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/example-bad-sheffield-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_MISSING_READINGS)
    end

    it 'handles a wrong file format' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/example-bad-sheffield-proper-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::WARNING_READING_DATE_MISSING)
    end
  end

  describe 'with row per reading' do
    let!(:config) do
      create(:amr_data_feed_config,
                                          date_format: '%d %b %Y %H:%M:%S',
                                          mpan_mprn_field: 'MPR',
                                          reading_date_field: 'ReadDatetime',
                                          reading_fields: ['kWh'],
                                          column_separator: ',',
                                          header_example: 'MPR,ReadDatetime,kWh,ReadType',
                                          row_per_reading: true,
                                          number_of_header_rows: 2)
    end

    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'AMR Data feed configuration'
      within '#configuration-overview' do
        click_on config.description
      end
      click_on 'Upload file'
    end

    it 'handles a correct file format' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/example-highlands-file.csv')
      expect { click_on 'Preview' }.to change(AmrUploadedReading, :count).by 1

      expect(AmrUploadedReading.count).to be 1
      expect(AmrUploadedReading.first.imported).to be false

      expect(page).not_to have_content('We have identified a problem')
      expect(page).to have_content('Data preview')
      expect(page).to have_content('1712423842469')

      expect { click_on 'Insert this data' }.to change(ManualDataLoadRun, :count).by(1)

      expect(page).to have_content('Processing')
    end

    it 'handles a wrong file format' do
      attach_file('amr_uploaded_reading[data_file]', 'spec/fixtures/amr_upload_data_files/example-sheffield-file.csv')
      click_on 'Preview'
      expect(page).to have_content(AmrReadingData::ERROR_UNABLE_TO_PARSE_FILE)
    end
  end
end

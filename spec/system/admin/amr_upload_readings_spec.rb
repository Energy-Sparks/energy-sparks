require 'rails_helper'

describe AmrUploadReading, type: :system do

  let!(:admin)              { create(:admin) }
  let!(:config)             { create(:amr_data_feed_config) }

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'AMR Data feed configuration'
    click_on 'Upload file'
  end

  it 'can upload a file' do
    # attach_file('amr_uploaded_reading[csv_file]', 'path/to/file.csv')
  end
end

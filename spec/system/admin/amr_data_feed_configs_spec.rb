require 'rails_helper'

describe AmrDataFeedConfig, type: :system do

  let!(:admin)              { create(:admin) }
  let!(:config)             { create(:amr_data_feed_config) }

  before(:each) do
    sign_in(admin)
    visit root_path
  end

  it 'can view amr data feed configuration' do
    click_on 'Manage'
    click_on 'AMR Data feed configuration'
    expect(page).to have_content(config.description)
    click_on config.description
    expect(page).to have_content(config.total_field)
  end
end

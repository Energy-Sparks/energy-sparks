require 'rails_helper'

RSpec.describe HelpPage, type: :model do
  let!(:help_page_1) { HelpPage.create(title: 'one', feature: 0) }
  let!(:help_page_2) { HelpPage.create(title: 'two', feature: 1) }

  it "#tx_resources" do
    expect(HelpPage.tx_resources).to match_array([help_page_1, help_page_2])
  end
end

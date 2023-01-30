require 'rails_helper'

RSpec.describe "gas costs advice page", type: :system do

  let(:school) { create(:school) }
  let(:key) { 'gas_costs' }
  let(:learn_more) { 'here is some more explanation' }
  let!(:advice_page) { create(:advice_page, key: key, restricted: false, learn_more: learn_more) }
  let(:expected_page_title) { "Gas cost analysis" }

  it_behaves_like "an advice page", key: 'gas_costs'
end

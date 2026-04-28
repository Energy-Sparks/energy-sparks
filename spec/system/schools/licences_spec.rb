# frozen_string_literal: true

require 'rails_helper'

describe 'school licences' do
  include AdvicePageHelper

  let(:user) { create(:admin) }
  let!(:school) { create(:school, :with_school_group, number_of_pupils: 100) }
  let!(:product) { create(:commercial_product, :default_product) }
  let!(:licence) do
    create(:commercial_licence,
           contract: create(:commercial_contract, product:),
           school:)
  end

  before do
    sign_in(user)
    visit admin_school_licences_path(school)
  end

  it { expect(page).to have_css('div.commercial-licences-component') }
  it { expect(page).to have_content("##{licence.id}") }

  it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
    let(:table_id) { '#pricing-table' }
    let(:expected_header) do
      [
        ['', 'Cost']
      ]
    end
    let(:expected_rows) do
      [
        ['Base Price', format_unit(product.small_school_price, :£, true, :ks2, :text)],
        ['Metering Fee', format_unit(0.0, :£, true, :ks2, :text)],
        ['Private Account Fee', format_unit(0.0, :£, true, :ks2, :text)],
        ['Total Price', format_unit(product.small_school_price, :£, true, :ks2, :text)]
      ]
    end
  end

  it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
    let(:table_id) { '#renewal-pricing-table' }
    let(:expected_header) do
      [
        ['', 'Cost']
      ]
    end
    let(:expected_rows) do
      [
        ['Base Price', format_unit(product.small_school_price, :£, true, :ks2, :text)],
        ['Metering Fee', format_unit(0.0, :£, true, :ks2, :text)],
        ['Private Account Fee', format_unit(0.0, :£, true, :ks2, :text)],
        ['Total Price', format_unit(product.small_school_price, :£, true, :ks2, :text)]
      ]
    end
  end
end

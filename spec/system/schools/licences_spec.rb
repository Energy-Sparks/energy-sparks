# frozen_string_literal: true

require 'rails_helper'

describe 'school licences', :include_application_helper do
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
  it { expect(page).to have_text("##{licence.id}") }
end

# frozen_string_literal: true

RSpec.shared_context 'with a mixture of contracted schools and onboardings' do
  let(:contract_holder) { create(:funder) }
  before do
    contract = create(:commercial_contract, contract_holder:)
    2.times do
      create(:commercial_licence, contract:, school: create(:school, data_enabled: false))
    end
    3.times do
      create(:commercial_licence, contract:, school: create(:school, data_enabled: true))
    end
    create(:school_onboarding, contract:, school: nil)
  end
end

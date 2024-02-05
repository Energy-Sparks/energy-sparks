require 'rails_helper'

RSpec.describe InterventionTypeGroup, type: :model do
  let!(:intervention_type_group_1) { InterventionTypeGroup.create(active: true, name: 'one') }
  let!(:intervention_type_group_2) { InterventionTypeGroup.create(active: false, name: 'two') }

  it '#tx_resources' do
    expect(InterventionTypeGroup.tx_resources).to match_array([intervention_type_group_1, intervention_type_group_2])
  end
end

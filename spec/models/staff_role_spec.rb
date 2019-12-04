require 'rails_helper'

describe StaffRole, type: :model do
  it 'converts the title to a sensible symbol' do
    expect(StaffRole.new(title: 'Third-party/other').as_symbol).to eq :third_party_other
    expect(StaffRole.new(title: 'Building/site manager or caretaker').as_symbol).to eq :building_site_manager_or_caretaker
  end
end

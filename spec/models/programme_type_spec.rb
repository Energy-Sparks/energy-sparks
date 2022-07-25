require 'rails_helper'

RSpec.describe ProgrammeType, type: :model do

  let!(:programme_type_1) { ProgrammeType.create(active: true, title: 'one') }
  let!(:programme_type_2) { ProgrammeType.create(active: false, title: 'two') }

  it "#tx_resources" do
    expect( ProgrammeType.tx_resources ).to match_array([programme_type_1])
  end
end

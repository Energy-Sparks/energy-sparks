require 'rails_helper'

RSpec.describe ProcurementRoute, type: :model do

  describe 'validations' do
    subject { build(:procurement_route) }
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:organisation_name) }
  end
end

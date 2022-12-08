require 'rails_helper'

RSpec.describe DataSource, type: :model do

  describe 'validations' do
    subject { build(:data_source) }
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'enums' do
    it { should define_enum_for(:organisation_type).with_values([:energy_supplier, :procurement_organisation, :meter_operator, :council, :solar_monitoring_provider]) }
  end
end

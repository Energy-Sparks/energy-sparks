require 'rails_helper'

describe AlertType do
  describe '#enabled' do
    it 'should return only alert types where enabled is set to true' do
      [false, true].each { |enabled_status| create(:alert_type, enabled: enabled_status) }
      expect(AlertType.count).to eq(2)
      expect(AlertType.enabled.count).to eq(1)
    end
  end
end

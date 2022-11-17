require 'rails_helper'

RSpec.describe DashboardMessage, type: :model do
  describe 'validations' do
    subject { build(:dashboard_message) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:message) }
  end
end

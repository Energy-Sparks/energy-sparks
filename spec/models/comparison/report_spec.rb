require 'rails_helper'

RSpec.describe Comparison::Report, type: :model do
  context 'with valid attributes' do
    subject(:report) { create :report }

    it { expect(report).to be_valid }
    it { expect(report).to validate_presence_of(:key) }
    it { expect(report).to validate_presence_of(:reporting_preiod) }
    it { expect(report).to validate_presence_of(:title) }
  end
end

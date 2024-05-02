require 'rails_helper'

RSpec.describe Comparison::Report, type: :model do
  describe 'validations' do
    context 'with standard validations' do
      subject(:report) { create :report }

      it { expect(report).to be_valid }
      it { expect(report).to validate_presence_of(:key) }
      it { expect(report).to validate_uniqueness_of(:key) }
      it { expect(report).to validate_presence_of(:title) }
      it { expect(report).not_to validate_presence_of(:introduction) }
      it { expect(report).not_to validate_presence_of(:notes) }
      it { expect(report).not_to validate_presence_of(:reporting_period) }
    end

    context 'with relationships' do
      subject(:report) { create :report }

      it { expect(report).to belong_to(:report_group) }
    end
  end

  it_behaves_like 'an enum reporting period', model: :report
end

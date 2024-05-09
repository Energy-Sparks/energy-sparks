require 'rails_helper'

RSpec.describe Comparison::ReportGroup, type: :model do
  describe 'validations' do
    context 'with standard validations' do
      subject(:report_group) { create :report_group }

      it { expect(report_group).to be_valid }
      it { expect(report_group).to validate_presence_of(:title) }
      it { expect(report_group).to validate_presence_of(:position) }
      it { expect(report_group).to validate_numericality_of(:position) }
    end

    context 'with relationships' do
      subject(:report_group) { create :report_group }

      it { expect(report_group).to have_many(:reports) }
    end
  end
end

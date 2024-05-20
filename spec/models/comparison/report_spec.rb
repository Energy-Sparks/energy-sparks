require 'rails_helper'

RSpec.describe Comparison::Report, type: :model do
  describe 'validations' do
    context 'with standard validations' do
      subject(:report) { build :report }

      it { expect(report).to be_valid }
      it { expect(report).to validate_uniqueness_of(:key) }
      it { expect(report).to validate_presence_of(:title) }
      it { expect(report).not_to validate_presence_of(:introduction) }
      it { expect(report).not_to validate_presence_of(:notes) }
      it { expect(report).not_to validate_presence_of(:reporting_period) }
    end
  end

  describe 'relationships' do
    subject(:report) { create :report }

    it { expect(report).to belong_to(:report_group).optional(false) }
  end

  describe '#key' do
    context 'when there is a title' do
      subject(:report) { create :report, title: 'Lovely title' }

      it 'builds a key on create using :title' do
        expect(report.key).to eq('lovely_title')
      end
    end

    context 'when there is no title' do
      subject(:report) { build :report, title: '' }

      it { expect(report).to validate_presence_of(:key) }
      it { expect(report).to validate_presence_of(:title) }
    end
  end

  it_behaves_like 'an enum reporting period', model: :report
end

require 'rails_helper'

RSpec.describe Comparison::Footnote, type: :model do
  describe 'validations' do
    context 'with valid attributes' do
      subject(:footnote) { create :footnote }

      it { expect(metric).to be_valid }
      it { expect(metric).to validate_presence_of(:key) }
      it { expect(metric).to validate_uniqueness_of(:key) }
      it { expect(metric).to validate_presence_of(:description) }
    end
  end
end

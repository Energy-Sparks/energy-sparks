# frozen_string_literal: true

RSpec.shared_examples 'has a contract holder' do
  let(:factory_name) do
    described_class.name.underscore.tr('/', '_').to_sym
  end

  valid_holders = {
    school: :school,
    school_group: :school_group,
    funder: :funder
  }

  valid_holders.each do |label, factory|
    context "when contract_holder is a #{label.to_s.camelize}" do
      subject { build(factory_name, contract_holder: build(factory)) }

      it { is_expected.to be_valid }
    end
  end

  context 'when contract_holder is an unsupported type' do
    subject { build(factory_name, contract_holder: build(:user)) }

    it 'is invalid' do
      expect(subject).not_to be_valid
      expect(subject.errors[:contract_holder]).to include(
        'must be a School, SchoolGroup, or Funder'
      )
    end
  end
end

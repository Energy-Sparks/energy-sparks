RSpec.shared_examples 'restricted school group association' do |factory|
  let(:restricted_group) { create(:school_group, group_type: :diocese) }

  subject { build(factory, school_group: restricted_group) }

  before { subject.valid? }

  it { expect(subject).to be_invalid }
  it { expect(subject.errors[:base]).to include('Cannot associate with school group of type: diocese') }
end

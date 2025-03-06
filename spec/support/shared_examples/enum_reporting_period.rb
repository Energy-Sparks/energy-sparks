RSpec.shared_examples 'an enum reporting period' do |model:|
  context 'when reporting period is :custom' do
    subject { build model, reporting_period: :custom }

    it { expect(subject).to validate_presence_of(:custom_period) }
  end

  context 'when reporting period is set to something other than :custom' do
    subject { build model, reporting_period: :last_12_months }

    it { expect(subject).not_to validate_presence_of(:custom_period) }
  end
end

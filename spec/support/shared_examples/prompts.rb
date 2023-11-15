RSpec.shared_examples "a standard prompt" do |displayed:|
  context "when displayed", if: displayed do
    it { expect(page).to have_content(message) }
  end

  context "when hidden", unless: displayed do
    it { expect(page).not_to have_content(message) }
  end
end

RSpec.shared_examples "dashboard message prompts" do |displayed:|
  include_examples "a standard prompt", displayed: displayed do
    let(:message) { "School group message" }
  end

  include_examples "a standard prompt", displayed: displayed do
    let(:message) { "School message" }
  end
end

RSpec.shared_examples "a training prompt" do |displayed:|
  let(:message) { "New to Energy Sparks? Sign up to one of our upcoming free online training courses to help you get the most from the service." }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a complete programme prompt" do |displayed:|
  let(:message) { "You have completed 0/3 of the activities" }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a recommendations prompt" do |displayed:|
  let(:message) { "Complete one of our recommended pupil or adult led activities to start reducing your energy usage" }
  it_behaves_like "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a functional training prompt" do
  context "when school is data enabled" do
    let(:data_enabled) { true }

    context "when user confirmed in the last 30 days" do
      let(:confirmed_at) { 2.days.ago }

      it_behaves_like "a training prompt", displayed: true
    end

    context "when user confirmed more than 30 days ago" do
      let(:confirmed_at) { 31.days.ago }

      it_behaves_like "a training prompt", displayed: false
    end
  end

  context "when school is not data enabled" do
    let(:data_enabled) { false }

    it_behaves_like "a training prompt", displayed: false

    context "when user confirmed more than 30 days ago" do
      let(:confirmed_at) { 31.days.ago }

      it_behaves_like "a training prompt", displayed: false
    end

    context "when user confirmed in the last 30 days" do
      let(:confirmed_at) { 2.days.ago }

      it_behaves_like "a training prompt", displayed: false
    end
  end
end

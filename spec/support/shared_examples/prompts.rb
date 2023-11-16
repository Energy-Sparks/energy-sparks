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
  let(:message) { "Start a new programme" }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a recommendations prompt" do |displayed:|
  let(:message) { "Complete one of our recommended pupil or adult led activities to start reducing your energy usage" }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a recommendations scoreboard prompt" do |displayed:|
  let(:message) { "You haven't scored any points this year. Complete your next activity to get on the scoreboard!" }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a transport survey prompt" do |displayed:|
  let(:message) { "Start a transport survey so that you can find out how much carbon your school community generates by travelling to school" }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a temperature measuring prompt" do |displayed:|
  let(:message) { "Measure classroom temperatures to find out whether you should turn down the heating to save energy" }

  include_examples "a standard prompt", displayed: displayed
end

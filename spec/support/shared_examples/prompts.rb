RSpec.shared_examples "a standard prompt" do |displayed:|
  it "is displayed", if: displayed do
    expect(page).to have_content(message)
  end

  it "is hidden", unless: displayed do
    expect(page).not_to have_content(message)
  end
end

RSpec.shared_examples "dashboard message prompts" do |displayed: true|
  include_examples "a standard prompt", displayed: displayed do
    let(:message) { "School group message" }
  end

  include_examples "a standard prompt", displayed: displayed do
    let(:message) { "School message" }
  end
end

RSpec.shared_examples "a training prompt" do |displayed: true|
  let(:message) { "New to Energy Sparks? Sign up to one of our upcoming free online training courses to help you get the most from the service." }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a complete programme prompt" do |displayed: true, with_programme: false|
  let(:message) do
    with_programme ? "You have completed 0/3 of the activities in the #{programme_type.title} programmeComplete the final 3 activities now to score 75 points and 12 bonus points for completing the programme" : "Start a new programme"
  end

  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a recommendations prompt" do |displayed: true|
  let(:message) { "Complete one of our recommended pupil or adult led activities to start reducing your energy usage" }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a recommendations scoreboard prompt" do |displayed: true|
  let(:message) { "You haven't scored any points this year. Complete your next activity to get on the scoreboard!" }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a transport survey prompt" do |displayed: true|
  let(:message) { "Start a transport survey so that you can find out how much carbon your school community generates by travelling to school" }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a temperature measuring prompt" do |displayed: true|
  let(:message) { "Measure classroom temperatures to find out whether you should turn down the heating to save energy" }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a basic audit prompt" do |displayed: true|
  let(:message) { "The Energy Sparks team have recently completed an energy audit for this school" }
  include_examples "a standard prompt", displayed: displayed
end

RSpec.shared_examples "a rich audit prompt" do |displayed: true|
  let(:message) { "You have completed 0/3 of the activities and 0/3 of the actions from your recent energy auditComplete the others to score 165 points and 50 bonus points for completing all audit tasks" }
  include_examples "a standard prompt", displayed: displayed
end

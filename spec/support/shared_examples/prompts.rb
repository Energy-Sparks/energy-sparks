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

RSpec.shared_examples "a recommendations scoreboard prompt" do |displayed: true, position: 0, points: 0|
  let(:no_position) { "You haven't scored any points this year. Complete your next activity to get on the scoreboard!" }
  let(:not_top) { "Well done, you have scored #{points} points so far and you're in #{position.ordinalize} position on the scoreboard. Complete your next activity to climb higher up the scoreboard!" }
  let(:top) { "Well done, you have scored #{points} points and you're in #{position.ordinalize} position on the scoreboard! Keep up the good work to help you stay top!" }

  let(:message) do
    case position
    when 0 then no_position
    when 1 then top
    else not_top
    end
  end

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

RSpec.shared_examples "a recommended prompt" do |displayed: true|
  let(:message) { "View our recommended activities and actions based on your school's programmes and our analysis of your energy data" }

  include_examples "a standard prompt", displayed: displayed
end

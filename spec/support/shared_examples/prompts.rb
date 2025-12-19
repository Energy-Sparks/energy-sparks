RSpec.shared_examples 'a standard prompt' do |displayed:|
  it 'is displayed', if: displayed do
    expect(page).to have_content(message)
  end

  it 'is hidden', unless: displayed do
    expect(page).not_to have_content(message)
  end
end

RSpec.shared_examples 'dashboard message prompts' do |displayed: true|
  include_examples 'a standard prompt', displayed: displayed do
    let(:message) { 'School group message' }
  end

  include_examples 'a standard prompt', displayed: displayed do
    let(:message) { 'School message' }
  end
end

RSpec.shared_examples 'a training prompt' do |displayed: true|
  let(:message) { 'New to Energy Sparks? Sign up to one of our upcoming free online training courses to help you get the most from the service.' }
  include_examples 'a standard prompt', displayed: displayed
end

RSpec.shared_examples 'a complete programme prompt' do |displayed: true, with_programme: false|
  let(:message) do
    with_programme ? "You haven't yet completed any of the tasks in the #{programme_type.title} programmeIf you complete them, you will score 165 points and 12 bonus points for completing the programme" : 'Start a new programme'
  end

  include_examples 'a standard prompt', displayed: displayed
end

RSpec.shared_examples 'a join programme prompt' do |displayed: true, programme:, task_count: nil, bonus_points: nil, completed: false|
  let(:incomplete) do
    "You've recently completed #{task_count == 1 ? 'a task that is' : "#{task_count} tasks that are"} part of the #{programme} programme. Do you want to enrol in the programme?"
  end

  let(:complete) do
    message = "You've completed all the tasks in the #{programme} programme. "
    if bonus_points == 0
      message += 'Mark it as complete?'
    else
      message += "Mark it done to score #{bonus_points} bonus points?"
    end
    message
  end

  let(:message) do
    if completed
      complete
    else
      incomplete
    end
  end

  include_examples 'a standard prompt', displayed: displayed
end

RSpec.shared_examples 'a no active programmes prompt' do |displayed: true|
  let(:message) { "Congratulations you've completed all your energy saving programmes! Time to choose your next programme" }

  include_examples 'a standard prompt', displayed: displayed
end

RSpec.shared_examples 'a recommendations prompt' do |displayed: true|
  let(:message) { 'Complete one of our recommended pupil or adult led activities to start reducing your energy usage' }

  include_examples 'a standard prompt', displayed: displayed
end

RSpec.shared_examples 'a transport survey prompt' do |displayed: true|
  let(:message) { 'Start a transport survey so that you can find out how much carbon your school community generates by travelling to school' }
  include_examples 'a standard prompt', displayed: displayed
end

RSpec.shared_examples 'a temperature measuring prompt' do |displayed: true|
  let(:message) { 'Measure classroom temperatures to find out whether you should turn down the heating to save energy' }
  include_examples 'a standard prompt', displayed: displayed
end

RSpec.shared_examples 'a basic audit prompt' do |displayed: true|
  let(:message) { 'The Energy Sparks team have recently completed an energy audit for this school' }
  include_examples 'a standard prompt', displayed: displayed
end

RSpec.shared_examples 'a rich audit prompt' do |displayed: true|
  let(:message) do
    "You haven't yet completed any of the tasks recommended in your recent energy auditIf you complete them, you will score 165 points and 50 bonus points for completing all audit tasks"
  end
  include_examples 'a standard prompt', displayed: displayed
end

RSpec.shared_examples 'a recommended prompt' do |displayed: true|
  let(:message) { "View our recommended activities and actions based on your school's programmes and our analysis of your energy data" }

  include_examples 'a standard prompt', displayed: displayed
end

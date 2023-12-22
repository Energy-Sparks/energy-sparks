RSpec.shared_examples "a task completed page" do |points:, task_type:, ordinal: '1st'|
  it { expect(page).to have_content "Congratulations!" }

  it "displays points score", if: points > 0 do
    expect(page).to have_content "You've just scored #{points} points"
  end

  it 'has no points action text', if: task_type == :action && points == 0 do
    expect(page).to have_content "We've recorded your activity"
  end

  it 'has no points activity text', if: task_type == :activity && points == 0 do
    expect(page).to have_content "We've recorded your activity"
  end

  it { expect(page).to have_content("Share what you’ve done with others in the school community") }
  it { expect(page).to have_link("View your #{task_type}") }

  it "has scoreboard summary component" do # not checking functionality here as this is done in the component
    within "div.podium-component" do
      expect(page).to have_content("You are in #{ordinal} place")
    end
    expect(page).to have_content("Recent activity")
  end

  it { expect(page).to have_content("What do you want to do next?") }

  it_behaves_like "a rich audit prompt"
  it_behaves_like "a complete programme prompt"
  it_behaves_like "a recommended prompt"
end

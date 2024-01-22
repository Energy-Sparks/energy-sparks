RSpec.shared_examples "a task completed page" do |points:, task_type:, ordinal: '1st'|
  it { expect(page).to have_content "Congratulations!" }

  it "displays points score", if: points > 0 do
    expect(page).to have_content "You've just scored #{points} points"
  end

  it 'has no points action text', if: task_type == :action && points == 0 do
    expect(page).to have_content "We've recorded your action"
  end

  it 'has no points activity text', if: task_type == :activity && points == 0 do
    expect(page).to have_content "We've recorded your activity"
  end

  it "has scoreboard summary component" do # not checking functionality here as this is done in the component
    within "div.podium-component" do
      if points > 0
        expect(page).to have_content("You are in #{ordinal} place")
      else
        expect(page).to have_content("Your school hasn't scored any points yet this school year")
      end
    end
    expect(page).to have_content("Recent activity")
  end

  it { expect(page).to have_content("What do you want to do next?") }

  it { expect(page).to have_content("Share what you’ve done with others in the school community") }
  it { expect(page).to have_link("View your #{task_type}") }

  it_behaves_like "a rich audit prompt"
  it_behaves_like "a complete programme prompt"
  it_behaves_like "a join programme prompt"
  it_behaves_like "a recommended prompt"
end

RSpec.shared_examples "a task completed page with programme complete message" do
  context "when there is a programme that contains activity" do
    let(:activity_types) { [] }
    let(:bonus_score) { 30 }
    let(:programme_type) { create(:programme_type, title: "Super programme!", activity_types: activity_types, bonus_score: bonus_score) }
    let(:programme) { create(:programme, school: school, programme_type: programme_type) }

    context "when programme is completed" do
      let(:activity_types) { [activity_type] }

      context "when recently ended" do
        it 'has programme completed message' do
          expect(page).to have_content "Well done, you've just completed the Super programme! programme and have earned 30 bonus points!"
        end

        it { expect(page).to have_link("View") }
      end

      context "when bonus was zero" do
        let(:bonus_score) { 0 }

        it 'shows the programme complete message' do
          expect(page).to have_content("Well done, you've just completed the Super programme! programme!")
        end

        it 'does not show bonus points message' do
          expect(page).not_to have_content "and have earned 30 bonus points!"
        end

        it { expect(page).to have_link("View") }
      end

      context "when ended over a day ago" do
        before do
          programme.update(ended_on: 3.days.ago)
          refresh
        end

        it 'does not show programme completed message' do
          expect(page).not_to have_content "Well done, you've just completed the Super programme! programme and have earned 30 bonus points!"
        end
      end
    end

    context "when programme isn't complete" do
      let(:activity_types) { [create(:activity_type), activity_type] }

      it 'does not show programme completed message' do
        expect(page).not_to have_content "Well done, you've just completed the Super programme! programme and have earned 30 bonus points!"
      end
    end
  end
end

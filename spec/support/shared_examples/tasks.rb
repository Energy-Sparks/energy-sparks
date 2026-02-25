RSpec.shared_examples 'a task completed page' do |points:, task_type:, ordinal: '1st', with_todos: false|
  it { expect(page).to have_content 'Congratulations!' }

  it 'displays points score', if: points > 0 do
    if defined? future_academic_year
      expect(page).to have_content "You've just scored #{points} points for the #{future_academic_year} academic year"
    else
      expect(page).to have_content "You've just scored #{points} points"
    end
  end

  it 'has no points action text', if: task_type == :action && points == 0 do
    expect(page).to have_content "We've recorded your action"
  end

  it 'has no points activity text', if: task_type == :activity && points == 0 do
    expect(page).to have_content "We've recorded your activity"
  end

  it 'has scoreboard summary component' do # not checking functionality here as this is done in the component
    within 'div.scoreboards-podium-component' do
      if !defined?(future_academic_year) && points > 0
        expect(page).to have_content("You are in #{ordinal} place")
      else
        expect(page).to have_content("Your school hasn't scored any points yet this school year")
      end
    end
    expect(page).to have_content('Recent activity')
  end

  it { expect(page).to have_content('What do you want to do next?') }

  it { expect(page).to have_content('Share what you’ve done with others in the school community') }
  it { expect(page).to have_link("View your #{task_type}") }

  it_behaves_like 'a rich audit prompt'
  it_behaves_like 'a complete programme prompt'

  it_behaves_like 'a join programme prompt', programme: 'Other programme!', task_count: 1 do
    let(:setup_data) do
      if with_todos
        activity_type = create(:programme_type, :with_todos, title: 'Other programme!').activity_type_tasks.first
      else
        activity_type = create(:programme_type_with_activity_types, title: 'Other programme!').activity_types.first
      end
      school.activities.create!(activity_type: activity_type, activity_category: activity_type.activity_category, happened_on: Time.zone.now)
    end
  end

  it_behaves_like 'a recommended prompt'
end

RSpec.shared_examples 'a task completed page with programme complete message' do |with_todos: false, task_type:|
  context 'when there is a programme type that contains task' do
    let(:activity_types) { [] }
    let(:intervention_types) { [] }
    let(:bonus_score) { 30 }
    let(:programme_type) do
      if with_todos
        create(:programme_type, title: 'Super programme!', activity_type_tasks: activity_types, intervention_type_tasks: intervention_types, bonus_score: bonus_score)
      else
        create(:programme_type, title: 'Super programme!', activity_types: activity_types, bonus_score: bonus_score)
      end
    end
    let(:programme) { create(:programme, school: school, programme_type: programme_type) }

    context 'when task is an activity', if: task_type == :activity do
      context 'when programme is completed' do
        let(:activity_types) { [activity_type] }

        context 'when recently ended' do
          it 'has programme completed message' do
            expect(page).to have_content "Well done, you've just completed the Super programme! programme and have earned 30 bonus points!"
          end

          it { expect(page).to have_link('View') }
        end

        context 'when bonus was zero' do
          let(:bonus_score) { 0 }

          it 'shows the programme complete message' do
            expect(page).to have_content("Well done, you've just completed the Super programme! programme!")
          end

          it 'does not show bonus points message' do
            expect(page).not_to have_content 'and have earned 30 bonus points!'
          end

          it { expect(page).to have_link('View') }
        end

        context 'when ended over a day ago' do
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

    context 'when task is an intervention', if: task_type == :action do
      context 'when programme is completed' do
        let(:intervention_types) { [intervention_type] }

        context 'when recently ended' do
          it 'has programme completed message' do
            expect(page).to have_content "Well done, you've just completed the Super programme! programme and have earned 30 bonus points!"
          end

          it { expect(page).to have_link('View') }
        end

        context 'when bonus was zero' do
          let(:bonus_score) { 0 }

          it 'shows the programme complete message' do
            expect(page).to have_content("Well done, you've just completed the Super programme! programme!")
          end

          it 'does not show bonus points message' do
            expect(page).not_to have_content 'and have earned 30 bonus points!'
          end

          it { expect(page).to have_link('View') }
        end

        context 'when ended over a day ago' do
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
        let(:intervention_types) { [create(:intervention_type), intervention_type] }

        it 'does not show programme completed message' do
          expect(page).not_to have_content "Well done, you've just completed the Super programme! programme and have earned 30 bonus points!"
        end
      end
    end
  end
end

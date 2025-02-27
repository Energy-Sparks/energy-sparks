require 'rails_helper'

describe Programmes::Creator do
  let(:calendar)        { create(:school_calendar, :with_academic_years, academic_year_count: 2) }
  let(:school)          { create(:school, calendar: calendar) }

  context with_feature: :todos do
    let(:programme_type) { create(:programme_type, :with_todos) }

    let(:service) { Programmes::Creator.new(school, programme_type) }

    describe '#create' do
      let(:programme) { school.programmes.first }

      context 'when school has no activities' do
        before do
          service.create
        end

        it 'creates school programme' do
          expect(school.programmes.count).to be 1
          expect(programme.programme_type).to eql programme_type
        end

        it 'starts programme today' do
          expect(programme.started_on).to eql Time.zone.today
        end

        it 'marks programme as started' do
          expect(programme.started?).to be true
        end

        it 'doesnt create any completed todos by default' do
          expect(programme.completed_todos.any?).to be false
        end

        it 'does not have a completed todo' do
          expect(school.programmes.first.completed_todos.any?).to be false
        end

        it 'doesnt enrol twice' do
          service.create
          expect(school.programmes.count).to be 1
        end

        it 'doesnt enrol twice when multiple programmes' do
          programme_type_other = create(:programme_type)
          school.programmes << create(:programme, programme_type: programme_type_other, started_on: Time.zone.now)
          service.create
          expect(school.programmes.count).to be 2
        end
      end

      context 'when school has recent recordings in programme' do
        let!(:activity) { create(:activity_without_creator, school: school, activity_type: programme_type.activity_type_tasks.first)}
        let!(:observation) { create(:observation, :intervention, school: school, intervention_type: programme_type.intervention_type_tasks.first)}

        before do
          service.create
        end

        it 'recognises progress when recent' do
          expect(programme.completed_activity_types.count).to be 1
          expect(programme.completed_intervention_types.count).to be 1
          expect(programme.completed_todos.any?).to be true
          expect(programme.completed_todos.activity_types.first.recording).to eq activity
          expect(programme.completed_todos.intervention_types.first.recording).to eq observation
        end

        it 'has a status of started' do
          expect(programme).to be_started
        end
      end

      context 'when school has multiple activities' do
        let!(:activities) do
          [1.hour.ago, 3.days.ago, 1.year.ago].map do |time|
            create(:activity_without_creator, school: school, activity_type: programme_type.activity_type_tasks.first, happened_on: time)
          end
        end
        let!(:observations) do
          [1.hour.ago, 3.days.ago, 1.year.ago].map do |time|
            create(:observation, :intervention, school: school, intervention_type: programme_type.intervention_type_tasks.first, at: time)
          end
        end

        before do
          service.create
        end

        it 'recognises the most recent' do
          expect(programme.completed_activity_types.count).to be 1
          expect(programme.completed_intervention_types.count).to be 1

          expect(programme.completed_todos.activity_types.first.recording).to eq activities.first
          expect(programme.completed_todos.intervention_types.first.recording).to eq observations.first
        end

        it 'has a status of started' do
          expect(programme).to be_started
        end
      end

      context 'when school has completed all activities and actions in programme this year' do
        before do
          programme_type.activity_type_tasks.each do |activity_type|
            create(:activity_without_creator, school: school, activity_type: activity_type, happened_on: Time.zone.now)
          end
          programme_type.intervention_type_tasks.each do |intervention_type|
            create(:observation, :intervention, school:, intervention_type: intervention_type, at: Time.zone.now)
          end

          service.create
        end

        it 'adds completed todos for each type' do
          expect(programme.completed_todos.count).to eq(programme_type.todos.count)
        end

        it 'marks programme as completed' do
          expect(programme).to be_completed
        end
      end

      context 'when school recorded an activity last year' do
        let!(:activity) { create(:activity_without_creator, school: school, activity_type: programme_type.activity_type_tasks.first, happened_on: Time.zone.today.last_year)}

        before do
          service.create
        end

        it 'this doesnt count towards progress' do
          expect(programme.completed_todos.count).to be 0
          expect(programme.completed_todos.any?).to be false
        end
      end
    end
  end

  context without_feature: :todos do
    let(:programme_type) { create(:programme_type_with_activity_types) }

    let(:service) { Programmes::Creator.new(school, programme_type) }

    describe '#create' do
      let(:programme) { school.programmes.first }

      context 'when school has no activities' do
        before do
          service.create
        end

        it 'creates school programme' do
          expect(school.programmes.count).to be 1
          expect(programme.programme_type).to eql programme_type
        end

        it 'starts programme today' do
          expect(programme.started_on).to eql Time.zone.today
        end

        it 'marks programme as started' do
          expect(programme.started?).to be true
        end

        it 'doesnt create any programme activities by default' do
          expect(programme.programme_activities.any?).to be false
        end

        it 'does not have an activity' do
          expect(school.programmes.first.activities.any?).to be false
        end

        it 'doesnt enrol twice' do
          service.create
          expect(school.programmes.count).to be 1
        end

        it 'doesnt enrol twice when multiple programmes' do
          programme_type_other = create(:programme_type)
          school.programmes << create(:programme, programme_type: programme_type_other, started_on: Time.zone.now)
          service.create
          expect(school.programmes.count).to be 2
        end
      end

      context 'when school has recent activity in programme' do
        let!(:activity) { create(:activity, school: school, activity_type: programme_type.activity_types.first)}

        before do
          service.create
        end

        it 'recognises progress when recent' do
          expect(programme.programme_activities.count).to be 1
          expect(programme.activities.any?).to be true
          expect(programme.activities.first).to eq activity
        end

        it 'has a status of started' do
          expect(programme).to be_started
        end
      end

      context 'when school has multiple activities' do
        let!(:activities) do
          [1.hour.ago, 3.days.ago, 1.year.ago].map do |time|
            create(:activity, school: school, activity_type: programme_type.activity_types.first, happened_on: time)
          end
        end

        before do
          service.create
        end

        it 'recognises the most recent' do
          expect(programme.programme_activities.count).to be 1
          expect(programme.activities.first).to eq activities.first
        end

        it 'has a status of started' do
          expect(programme).to be_started
        end
      end

      context 'when school has completed all activities in programme this year' do
        before do
          programme_type.activity_types.each do |activity_type|
            create(:activity, school: school, activity_type: activity_type, happened_on: Time.zone.now)
          end

          service.create
        end

        it 'adds programme activity for each type' do
          expect(programme.programme_activities.count).to eq(programme_type.activity_types.count)
        end

        it 'marks programme as completed' do
          expect(programme).to be_completed
        end
      end

      context 'when school recorded an activity last year' do
        let!(:activity) { create(:activity, school: school, activity_type: programme_type.activity_types.first, happened_on: Time.zone.today.last_year)}

        before do
          service.create
        end

        it 'this doesnt count towards progress' do
          expect(programme.programme_activities.count).to be 0
          expect(programme.activities.any?).to be false
        end
      end
    end
  end
end

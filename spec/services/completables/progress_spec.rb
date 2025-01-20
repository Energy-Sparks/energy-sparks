# frozen_string_literal: true

require 'rails_helper'

describe Completables::Progress, type: :service do
  let!(:school) { create(:school) }
  let(:service) { described_class.new(completable) }

  let(:activity_type_factory_score) { 25 }
  let(:intervention_type_factory_score) { 30 }

  let(:message) { service.message }
  let(:summary) { service.summary }

  context 'when completable is a programme' do
    context 'when programme has both activities and actions' do
      let!(:assignable) { create(:programme_type, :with_todos, title: 'Programme Type title', bonus_score: 12) }
      let!(:completable) { create(:programme, programme_type: assignable, started_on: '2020-01-01', school:) }

      describe '#title' do
        it 'returns the title' do
          expect(service.title).to eq(assignable.title)
        end
      end

      describe '#bonus_points' do
        it 'returns the bonus score' do
          expect(service.bonus_points).to eq(assignable.bonus_score)
        end
      end

      context 'when no tasks have been completed' do
        describe '#notification' do
          let(:expected_score) { activity_type_factory_score * 3 + intervention_type_factory_score * 3 }

          it 'returns the message' do
            expect(service.message).to eq("You haven't yet completed any of the tasks " \
                                    'in the <strong>Programme Type title</strong> programme')
          end

          it 'shows full summary' do
            expect(service.summary).to eq("If you complete them, you will score <strong>#{expected_score}</strong> points "\
                                    'and <strong>12</strong> bonus points for completing the programme')
          end

          context 'with no bonus points available' do
            before do
              assignable.update!(bonus_score: 0)
            end

            it 'shows full summary' do
              expect(service.summary).to eq("If you complete them, you will score <strong>#{expected_score}</strong> points")
            end
          end
        end
      end

      context 'when one activity has been completed' do
        let(:recording) do
          build(:activity, school:, activity_type: assignable.activity_type_tasks.first, happened_on: Date.yesterday)
        end

        let(:expected_score) { activity_type_factory_score * 2 + intervention_type_factory_score * 3 }

        before do
          Tasks::Recorder.new(recording, nil).process
        end

        it 'returns the message' do
          expect(message).to eq('You have completed <strong>1/6</strong> of the tasks ' \
                                'in the <strong>Programme Type title</strong> programme')
        end

        it 'returns the summary' do
          expect(summary).to eq("Complete the final <strong>5</strong> tasks now to score <strong>#{expected_score}</strong> points "\
                                'and <strong>12</strong> bonus points for completing the programme')
        end

        context 'with no bonus points available' do
          before do
            assignable.update!(bonus_score: 0)
          end

          it 'shows full summary' do
            expect(summary).to eq("Complete the final <strong>5</strong> tasks now to score <strong>#{expected_score}</strong> points")
          end
        end
      end

      context 'when one action has been completed' do
        let(:recording) do
          build(:observation, :intervention, school:, intervention_type: assignable.intervention_type_tasks.first, at: Date.yesterday)
        end
        let(:expected_score) { activity_type_factory_score * 3 + intervention_type_factory_score * 2 }

        before do
          Tasks::Recorder.new(recording, nil).process
        end


        it 'returns the message' do
          expect(message).to eq('You have completed <strong>1/6</strong> of the tasks ' \
                                'in the <strong>Programme Type title</strong> programme')
        end

        it 'returns the summary' do
          expect(summary).to eq("Complete the final <strong>5</strong> tasks now to score <strong>#{expected_score}</strong> points "\
                                'and <strong>12</strong> bonus points for completing the programme')
        end

        context 'with no bonus points available' do
          before do
            assignable.update!(bonus_score: 0)
          end

          it 'shows full summary' do
            expect(summary).to eq("Complete the final <strong>5</strong> tasks now to score <strong>#{expected_score}</strong> points")
          end
        end
      end

      context 'when all but one have been completed' do
        before do
          recordings = []
          assignable.activity_type_tasks.first(2).each do |activity_type|
            recordings << build(:activity, school:, activity_type:, happened_on: Date.yesterday)
          end
          assignable.intervention_type_tasks.each do |intervention_type|
            recordings << build(:observation, :intervention, school:, intervention_type:, at: Date.yesterday)
          end
          recordings.each {|recording| Tasks::Recorder.new(recording, nil).process }
        end

        let(:expected_score) { activity_type_factory_score * 1}

        it 'returns the message' do
          expect(service.message).to eq('You have completed <strong>5/6</strong> of the tasks ' \
                                'in the <strong>Programme Type title</strong> programme')
        end

        it 'returns the summary' do
          expect(service.summary).to eq("Complete the final task now to score <strong>#{expected_score}</strong> points "\
                                'and <strong>12</strong> bonus points for completing the programme')
        end

        context 'with no bonus points available' do
          before do
            assignable.update!(bonus_score: 0)
          end

          it 'shows full summary' do
            expect(summary).to eq("Complete the final task now to score <strong>#{expected_score}</strong> points")
          end
        end
      end
    end
  end

  context 'when completable is an audit' do
    let!(:site_settings) { SiteSettings.create!(audit_activities_bonus_points: 50) }

    let(:created_at) { 3.days.ago }
    let!(:assignable) { create(:audit, :with_todos, created_at:, school:) }
    let!(:completable) { assignable }

    describe '#bonus_points' do
      it 'returns the bonus score' do
        expect(service.bonus_points).to eq(50)
      end
    end

    context 'when no tasks have been completed' do
      let(:expected_score) { activity_type_factory_score * 3 + intervention_type_factory_score * 3 }

      it 'shows message' do
        expect(service.message).to eq("You haven't yet completed any of the tasks recommended in your recent energy audit")
      end

      it 'shows summary' do
        expect(service.summary).to eq("If you complete them, you will score <strong>#{expected_score}</strong> points " \
                                'and <strong>50</strong> bonus points for completing all audit tasks')
      end
    end

    context 'when audit was created over a year ago' do
      let(:created_at) { 3.years.ago }

      describe '#notification' do
        it { expect(service.notification).not_to include('recent') }
      end
    end

    context 'when one activity has been completed' do
      let(:recording) do
        build(:activity, school:, activity_type: assignable.activity_type_tasks.first, happened_on: Date.yesterday)
      end

      before do
        Tasks::Recorder.new(recording, nil).process
      end

      describe '#message' do
        subject(:message) { service.message }

        it 'returns the message' do
          expect(message).to eq('You have completed <strong>1/6</strong> of the tasks ' \
                                'from your recent energy audit')
        end
      end

      describe '#summary' do
        subject(:summary) { service.summary }

        let(:expected_score) { activity_type_factory_score * 2 + intervention_type_factory_score * 3 }

        it 'returns the summary' do
          expect(summary).to eq("Complete the others to score <strong>#{expected_score}</strong> points "\
                                'and <strong>50</strong> bonus points for completing all audit tasks')
        end
      end
    end

    context 'when one action has been completed' do
      let(:recording) do
        build(:observation, :intervention, school:, intervention_type: assignable.intervention_type_tasks.first, at: Date.yesterday)
      end

      before do
        Tasks::Recorder.new(recording, nil).process
      end

      describe '#message' do
        subject(:message) { service.message }

        it 'returns the message' do
          expect(message).to eq('You have completed <strong>1/6</strong> of the tasks ' \
                                'from your recent energy audit')
        end
      end

      describe '#summary' do
        subject(:summary) { service.summary }

        let(:expected_score) { activity_type_factory_score * 3 + intervention_type_factory_score * 2 }

        it 'returns the summary' do
          expect(summary).to eq("Complete the others to score <strong>#{expected_score}</strong> points "\
                                'and <strong>50</strong> bonus points for completing all audit tasks')
        end
      end
    end

    context 'when all but one have been completed' do
      before do
        recordings = []
        assignable.activity_type_tasks.first(2).each do |activity_type|
          recordings << build(:activity, school:, activity_type:, happened_on: Date.yesterday)
        end
        assignable.intervention_type_tasks.each do |intervention_type|
          recordings << build(:observation, :intervention, school:, intervention_type:, at: Date.yesterday)
        end
        recordings.each {|recording| Tasks::Recorder.new(recording, nil).process }
      end

      let(:expected_score) { activity_type_factory_score * 1}

      it 'returns the message' do
        expect(service.message).to eq('You have completed <strong>5/6</strong> of the tasks ' \
                              'from your recent energy audit')
      end

      it 'returns the summary' do
        expect(service.summary).to eq("Complete the final task now to score <strong>#{expected_score}</strong> points "\
                                      'and <strong>50</strong> bonus points for completing all audit tasks')
      end
    end
  end
end

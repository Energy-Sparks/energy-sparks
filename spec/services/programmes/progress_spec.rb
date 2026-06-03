# frozen_string_literal: true

require 'rails_helper'

describe Programmes::Progress, type: :service do
  let!(:school) { create(:school) }
  let(:service) { described_class.new(programme) }

  let!(:activity_types) { create_list(:activity_type, 3, score: 25) }
  let!(:programme_type) { create(:programme_type, activity_types:, bonus_score: 12) }
  let!(:programme) { create(:programme, programme_type:, started_on: '2020-01-01', school:) }

  context 'when a programme activity has been completed' do
    let(:activity) do
      build(:activity, school:, activity_type: activity_types.first, happened_on: Date.yesterday)
    end

    before do
      ActivityCreator.new(activity, nil).process
    end

    describe '#notification' do
      context 'with bonus points' do
        it 'returns the full notification text used on the school dashboard' do
          expect(service.notification).to eq('You have completed <strong>1/3</strong> of the activities in the ' \
                                             "<strong>#{programme_type.title}</strong> programme<br />Complete the " \
                                             'final <strong>2</strong> activities now to score <strong>50</strong> ' \
                                             'points and <strong>12</strong> bonus points for completing the programme')
        end
      end

      context 'with no bonus points' do
        it 'returns the full notification text used on the school dashboard' do
          programme_type.update!(bonus_score: 0)
          expect(service.notification).to eq('You have completed <strong>1/3</strong> of the activities in the ' \
                                             "<strong>#{programme_type.title}</strong> programme<br />Complete the " \
                                             'final <strong>2</strong> activities now to score <strong>50</strong> ' \
                                             'points')
        end
      end
    end

    describe '#programme_points_for_completion' do
      it 'includes bonus points' do
        expect(service.programme_points_for_completion).to eq(12)
      end
    end

    describe '#activity_types_total_scores' do
      it 'sums the scores of all activity types associated with the programmes programme type' do
        expect(service.activity_types_total_scores).to eq(programme.programme_type.activity_types.sum(:score))
      end
    end

    describe '#programme_type_title' do
      it 'returns the programmes programme_type title' do
        expect(service.programme_type_title).to eq(programme_type.title)
      end
    end

    describe '#programme_activities' do
      it 'returns the programmes activities' do
        expect(service.programme_activities).to match_array(programme.activities)
      end
    end

    describe '#programme_activities_count' do
      it 'returns the count of the programmes activities which is the number of activities, of the programme, that the school has completed' do
        expect(service.programme_activities_count).to eq(1)
      end
    end

    describe '#activity_types' do
      it 'returns the programmes programme types activity types' do
        expect(service.activity_types).to match_array(programme.programme_type.activity_types)
      end
    end

    describe '#activity_types_count' do
      it 'returns the count programmes programme types activity types which is the number of different activity types associated with the programme' do
        expect(service.activity_types_count).to eq(3)
      end
    end

    describe '#activity_types_completed' do
      it 'returns all activity types that have been completed for the programme' do
        expect(service.activity_types_completed).to match_array(programme.activity_types_completed)
      end
    end

    describe '#activity_types_uncompleted_count' do
      it 'returns the difference between the number of activity types for the programme and those completed' do
        allow_any_instance_of(Programme).to receive(:activity_types_completed) {
                                              programme.programme_type.activity_types.limit(1)
                                            }
        expect(service.activity_types_uncompleted_count).to eq(2)
      end
    end
  end

  context 'no activities completed yet' do
    describe '#notification' do
      it 'returns the full notification text' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: true) }
        expect(service.notification).to eq("You have completed <strong>0/3</strong> of the activities in the <strong>#{programme_type.title}</strong> programme<br />Complete the final <strong>3</strong> activities now to score <strong>75</strong> points and <strong>12</strong> bonus points for completing the programme")
      end
    end
  end

  context 'with 1 activity left to complete' do
    let(:activity) do
      build(:activity, school:, activity_type: activity_types.first, happened_on: Date.yesterday)
    end

    before do
      activity_types.first(2).each do |activity_type|
        activity = build(:activity, school:, activity_type:, happened_on: Date.yesterday)
        ActivityCreator.new(activity, nil).process
      end
    end

    describe '#notification' do
      it 'returns the singular notification' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: true) }
        expect(service.notification).to eq("You have completed <strong>2/3</strong> of the activities in the <strong>#{programme_type.title}</strong> programme<br />Complete the final activity now to score <strong>25</strong> points and <strong>12</strong> bonus points for completing the programme")
      end
    end
  end
end

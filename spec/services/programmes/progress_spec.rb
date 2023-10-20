require 'rails_helper'

describe Programmes::Progress do
  let!(:school) { create(:school) }
  let!(:activity_types) { create_list(:activity_type, 3, score: 25) }
  let!(:programme_type) { create(:programme_type, activity_types: activity_types, bonus_score: 12) }
  let!(:programme) { create(:programme, programme_type: programme_type, started_on: '2020-01-01', school: school) }

  let(:service) { Programmes::Progress.new(programme) }

  context "no activities completed yet" do
    describe '#notification_text' do
      it 'returns the full notification text used on the school dashboard' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: true) }
        expect(service.notification_text).to eq("You have completed <strong>0/3</strong> of the activities in the <strong>#{programme_type.title}</strong> programme. Complete the final <strong>3</strong> activities now to score <span class=\"badge badge-success\">75</span> points and <span class=\"badge badge-success\">12</span> bonus points for completing the programme")
      end
    end
  end

  context "a programme activity has been completed" do
    let(:activity) { build(:activity, school: school, activity_type: activity_types.first, happened_on: Date.yesterday) }

    before do
      ActivityCreator.new(activity).process
    end

    describe '#notification_text' do
      context 'when the programme is completed within the same academic year as started' do
        it 'returns the full notification text used on the school dashboard' do
          allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: true) }
          expect(service.notification_text).to eq("You have completed <strong>1/3</strong> of the activities in the <strong>#{programme_type.title}</strong> programme. Complete the final <strong>2</strong> activities now to score <span class=\"badge badge-success\">50</span> points and <span class=\"badge badge-success\">12</span> bonus points for completing the programme")
        end
      end

      context 'when the programme is completed outside of the academic year as started' do
        it 'returns the full notification text used on the school dashboard' do
          allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: false) }
          expect(service.notification_text).to eq("You have completed <strong>1/3</strong> of the activities in the <strong>#{programme_type.title}</strong> programme. Complete the final <strong>2</strong> activities now to score <span class=\"badge badge-success\">50</span> points and <span class=\"badge badge-success\">0</span> bonus points for completing the programme")
        end
      end
    end

    describe "#programme_points_for_completion" do
      it 'includes bonus points if the programme is completed within the same academic year as started' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: true) }
        expect(service.programme_points_for_completion).to eq(12)
      end

      it 'excludes bonus points if the programme is completed outside of the academic year as started' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: false) }
        expect(service.programme_points_for_completion).to eq(0)
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
        allow_any_instance_of(Programme).to receive(:activity_types_completed) { programme.programme_type.activity_types.limit(1) }
        expect(service.activity_types_uncompleted_count).to eq(2)
      end
    end
  end
end

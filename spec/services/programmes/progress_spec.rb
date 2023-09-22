require 'rails_helper'

describe Programmes::Progress do

  let(:school) { create(:school) }
  let(:programme_type) { create(:programme_type_with_activity_types, bonus_score: 12) }
  let(:programme) { Programme.create!(programme_type: programme_type, started_on: '2020-01-01', school: school) }

  let(:service) { Programmes::Progress.new(programme) }

  describe '#notification_text' do
    context 'when the programme is completed within the same academic year as started' do
      it 'returns the full notification text used on the school dashboard' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: true) }
        expect(service.notification_text).to eq("You have completed 0/3 of the activities in the #{programme_type.title} programme. Complete the final 3 activities now to score 87 points")
      end
    end

    context 'when the programme is completed outside of the academic year as started' do
      it 'returns the full notification text used on the school dashboard' do
        allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: false) }
        expect(service.notification_text).to eq("You have completed 0/3 of the activities in the #{programme_type.title} programme. Complete the final 3 activities now to score 75 points")
      end
    end
  end

  describe "#total_points" do
    it 'includes bonus points if the programme is completed within the same academic year as started' do
      allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: true) }
      expect(service.total_points).to eq(87)
    end

    it 'excludes bonus points if the programme is completed outside of the academic year as started' do
      allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: false) }
      expect(service.total_points).to eq(75)
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
      expect(service.programme_activities_count).to eq(0)
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

  describe '#activity_types_completed_count' do
    it 'returns the count of all activity types that have been completed for the programme' do
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

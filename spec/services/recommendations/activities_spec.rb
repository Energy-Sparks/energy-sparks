require 'rails_helper'

describe Recommendations::Activities, type: :service do
  let(:ks1) { create :key_stage, name: 'KS1'}
  let(:key_stages) { [] }

  let(:school)    { create(:school, key_stages: key_stages) }
  let(:service)   { Recommendations::Activities.new(school) }

  let(:task_type) { :activity_type }
  let(:task_types) { :activity_types }

  include_context 'with recommendations context'

  def complete_task(task, school:, at:)
    create :activity, school: school, activity_type: task, happened_on: at
  end

  describe '#based_on_recent_activity' do
    subject(:recent_activity) { service.based_on_recent_activity(limit) }

    context 'when school has no key stages' do
      let(:key_stages) { [] }

      it_behaves_like 'a service making recommendations based on recent activity'
    end

    context 'when school has key stages' do
      let(:key_stages) { [ks1] }

      let!(:activity_type_ks1) { create(:activity_type, key_stages: [ks1]) }
      let!(:activity_type_ks_other) { create(:activity_type, key_stages: [create(:key_stage)]) }

      context 'when an action with suggestions in same key stage is completed' do
        let!(:activity_type) { create(:activity_type, suggested_types: [activity_type_ks1]) }

        before do
          complete_task(activity_type, school: school, at: this_academic_year)
        end

        it 'returns suggestions from same key stage' do
          expect(recent_activity).to include(activity_type_ks1)
        end
      end

      context 'when an action with suggestions in a different key stage is completed' do
        let!(:activity_type) { create(:activity_type, suggested_types: [activity_type_ks_other]) }

        before do
          complete_task(activity_type, school: school, at: this_academic_year)
        end

        it 'does not return suggestions from different key stage' do
          expect(recent_activity).not_to include(activity_type_ks_other)
        end
      end
    end
  end

  describe '#based_on_energy_use' do
    subject(:energy_use) { service.based_on_energy_use(limit) }

    context 'when school has no key stages' do
      let(:key_stages) { [] }

      it_behaves_like 'a service making recommendations based on energy use', with_todos: true
    end

    context 'when school has key stages' do
      let(:key_stages) { [ks1] }

      let!(:activity_type_ks1) { create(:activity_type, key_stages: [ks1]) }
      let!(:activity_type_ks_other) { create(:activity_type, key_stages: [create(:key_stage)]) }

      let!(:alert_generation_run) { create(:alert_generation_run, school: school)}
      let!(:alert_type) { create(:alert_type)}

      let!(:ks_one) { create(task_type, name: 'ks 1', key_stages: [ks1]) }
      let!(:ks_other) { create(task_type, name: 'ks other', key_stages: [create(:key_stage)]) }

      let!(:alert_type_rating) { create(:alert_type_rating, rating_from: 1.0, rating_to: 10.0, alert_type: alert_type, activity_types: [ks_one, ks_other]) }

      let!(:alert) do
        create(:alert,
          alert_generation_run: alert_generation_run,
          alert_type: alert_type,
          school: school,
          rating: 5
        )
      end

      it 'returns suggestions from the same key stage' do
        expect(energy_use).to include(ks_one)
      end

      it 'does not return recommendations from different key stages' do
        expect(energy_use).not_to include(ks_other)
      end
    end
  end
end

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

      it_behaves_like 'a service making recommendations based on energy use'
    end
  end
end

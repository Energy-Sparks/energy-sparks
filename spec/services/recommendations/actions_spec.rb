require 'rails_helper'

describe Recommendations::Actions, type: :service do
  let(:school)    { create(:school) }
  let(:service)   { Recommendations::Actions.new(school) }

  let(:task_type) { :intervention_type }
  let(:task_types) { :intervention_types }

  include_context 'with recommendations context'

  def complete_task(task, school:, at:)
    create(:observation, :intervention, school: school, at: at, intervention_type: task)
  end

  describe '#based_on_recent_activity' do
    subject(:recent_activity) { service.based_on_recent_activity(limit) }

    it_behaves_like 'a service making recommendations based on recent activity'
  end

  describe '#based_on_energy_use' do
    subject(:energy_use) { service.based_on_energy_use(limit) }

    it_behaves_like 'a service making recommendations based on energy use'
  end
end

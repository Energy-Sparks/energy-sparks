RSpec.shared_examples 'a service making recommendations based on recent activity' do
  let!(:task_type_1) { create(task_type) }
  let!(:task_type_2) { create(task_type) }
  let!(:task_type_3) { create(task_type, suggested_types: [task_type_1]) }
  let!(:task_type_4) { create(task_type) }

  context 'when an action with suggestions was completed this academic year' do
    before do
      complete_task(task_type_3, school: school, at: this_academic_year)
    end

    it 'does not included those completed this academic year' do
      expect(recent_activity).not_to include(task_type_3)
    end

    it 'returns suggestions from completed action first' do
      expect(recent_activity).to start_with(task_type_1)
    end

    it 'returns random from rest of available types' do
      expect(recent_activity[1..]).to match_array([task_type_2, task_type_4])
    end
  end

  context 'when an action was completed in a previous year' do
    before do
      complete_task(task_type_3, school: school, at: last_academic_year)
    end

    it 'includes those completed in previous years' do
      expect(recent_activity).to include(task_type_3)
    end

    it 'returns suggestions from completed action first' do
      expect(recent_activity).to start_with(task_type_1)
    end

    it 'returns random from available types' do
      expect(recent_activity[1..]).to match_array([task_type_2, task_type_3, task_type_4])
    end
  end

  context 'with more than limit suggested actions available' do
    let!(:task_type_4) { create(task_type, suggested_types: create_list(task_type, 5)) }

    before do
      complete_task(task_type_1, school: school, at: later_this_academic_year)
      complete_task(task_type_4, school: school, at: this_academic_year)
    end

    it 'returns limit items' do
      expect(recent_activity.count).to eq(5)
    end

    it 'returns suggestions from lastest completed action first' do
      expect(recent_activity).to start_with(task_type_1.suggested_types)
    end

    it 'returns last 4 suggestions from next completed action' do
      expect(recent_activity[1..].to_set).to be_subset(task_type_4.suggested_types.to_set)
    end
  end

  context 'with no tasks completed' do
    it 'suggests from random' do
      expect(recent_activity).to match_array([task_type_1, task_type_2, task_type_3, task_type_4])
    end
  end
end

RSpec.shared_examples 'a service making recommendations based on energy use' do
  let!(:alert_generation_run) { create(:alert_generation_run, school: school)}
  let!(:alert_type_elec) { create(:alert_type, fuel_type: :electricity)}
  let!(:alert_type_gas) { create(:alert_type, fuel_type: :gas)}

  let!(:elec) { 3.times.collect {|i| create(task_type, name: "elec #{i}") } }
  let!(:gas) { 3.times.collect {|i| create(task_type, name: "gas #{i}") } }

  let!(:alert_type_rating_elec) { create(:alert_type_rating, rating_from: 2.0, rating_to: 6.0, alert_type: alert_type_elec, "#{task_types}": elec) }
  let!(:alert_type_rating_gas) { create(:alert_type_rating, rating_from: 2.0, rating_to: 6.0, alert_type: alert_type_gas, "#{task_types}": gas) }

  let(:alert_rating_elec) { 4.0 }

  let!(:alert_elec) do
    create(:alert,
      alert_generation_run: alert_generation_run,
      alert_type: alert_type_elec,
      school: school,
      rating: alert_rating_elec
    )
  end

  let!(:alert_gas) do
    create(:alert,
      alert_generation_run: alert_generation_run,
      alert_type: alert_type_gas,
      school: school,
      rating: 5.0
    )
  end

  it 'includes ratings suggestions alternating by fuel type' do
    expect(energy_use).to eq([elec[0], gas[0], elec[1], gas[1], elec[2]])
  end

  context 'when an alert activity has been completed this year' do
    before do
      complete_task(elec[0], school: school, at: this_academic_year)
    end

    it 'does not include activities completed this year' do
      expect(energy_use).not_to include(elec[0])
    end
  end

  context "when alert rating isn't within alert type rating range" do
    let(:alert_rating_elec) { 1.0 }

    it 'does not include intervention types for alert rating' do
      expect(energy_use).not_to include(*elec)
    end
  end

  context 'when alert rating is nil' do
    let(:alert_rating_elec) { nil }

    it 'does not include intervention types for alert rating' do
      expect(energy_use).not_to include(*elec)
    end
  end

  context 'when there is an alert with higher rating' do
    let!(:one_gas) { [create(task_type, name: 'another gas')] }
    let!(:another_alert_type_gas) { create(:alert_type, fuel_type: :gas)}
    let!(:another_alert_type_rating_gas) { create(:alert_type_rating, rating_from: 1.0, rating_to: 10.0, alert_type: another_alert_type_gas, "#{task_types}": one_gas) }
    let!(:another_alert_gas) do
      create(:alert,
        alert_generation_run: alert_generation_run,
        alert_type: another_alert_type_gas,
        school: school,
        rating: 2.0
      )
    end

    it 'picks from alert with higher rating' do
      expect(energy_use).to include(*one_gas)
    end

    it 'includes ratings suggestions alternating by fuel type' do
      expect(energy_use.map { |task| task.name.include?('gas') ? :gas : :electricity }).to \
        eq(%i[gas electricity gas electricity gas])
    end
  end

  context 'when the alert type has no fuel' do
    let!(:no_fuel) { 3.times.collect {|i| create(task_type, name: "no fuel #{i}") } }
    let!(:alert_type_no_fuel) { create(:alert_type, fuel_type: nil)}
    let!(:alert_type_rating_no_fuel) { create(:alert_type_rating, rating_from: 1.0, rating_to: 10.0, alert_type: alert_type_no_fuel, "#{task_types}": no_fuel) }

    let!(:alert_no_fuel) do
      create(:alert,
        alert_generation_run: alert_generation_run,
        alert_type: alert_type_no_fuel,
        school: school,
        rating: 2.0
      )
    end

    it 'includes ratings suggestions alternating by fuel type' do
      expect(energy_use).to eq([no_fuel[0], elec[0], gas[0], no_fuel[1], elec[1]])
    end
  end

  context 'when alert types have same suggestions' do
    let!(:gas) { elec }

    it 'includes them once only' do
      expect(energy_use).to eq([elec[0], elec[1], elec[2]])
    end
  end

  context 'when there is no alert generation run for school' do
    let(:alert_generation_run) {}

    it { expect(energy_use).to be_empty }
  end

  context 'when there are no alerts for school' do
    let!(:alert_elec) {}
    let!(:alert_gas) {}

    it { expect(energy_use).to be_empty }

    context 'when school has suggested actions from an audit' do
      let!(:audit) do
        create(:audit, school: school, "#{task_type}_todos": create_list("#{task_type}_todo", 6))
      end

      let(:audit_task_types) do
        audit.send("#{task_type}_tasks")
      end

      it 'tops up from them' do
        expect(energy_use).to all(be_in(audit_task_types))
      end

      context 'when one has been recently completed' do
        before do
          complete_task(audit_task_types[0], school: school, at: this_academic_year)
        end

        it 'is not included in the results' do
          expect(energy_use).not_to include(audit_task_types[0])
        end
      end
    end
  end
end

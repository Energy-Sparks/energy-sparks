require 'rails_helper'

describe Recommendations::Actions, type: :service do
  let(:service)   { Recommendations::Actions.new(school) }

  let(:school)    { create(:school) }
  let(:academic_year) { school.calendar.academic_years.last }
  let(:this_academic_year) { academic_year.start_date + 1.month }
  let(:later_this_academic_year) { academic_year.start_date + 2.months }
  let(:last_academic_year) { academic_year.start_date - 1.month }

  describe '#based_on_recent_activity' do
    let!(:intervention_type_1) { create(:intervention_type) }
    let!(:intervention_type_2) { create(:intervention_type) }
    let!(:intervention_type_3) { create(:intervention_type, suggested_types: [intervention_type_1]) }
    let!(:intervention_type_4) { create(:intervention_type) }


    let(:limit) { 5 }

    subject(:recent_activity) { service.based_on_recent_activity(limit) }

    context 'when an action with suggestions was completed this academic year' do
      before do
        create(:observation, :intervention, school: school, at: this_academic_year, intervention_type: intervention_type_3)
      end

      it 'does not included those completed this academic year' do
        expect(recent_activity).not_to include(intervention_type_3)
      end

      it 'returns suggestions from completed action first' do
        expect(recent_activity).to start_with(intervention_type_1)
      end

      it 'returns random from rest of available types' do
        expect(recent_activity[1..]).to match_array([intervention_type_2, intervention_type_4])
      end
    end

    context 'when an action was completed in a previous year' do
      before do
        create(:observation, :intervention, school: school, at: last_academic_year, intervention_type: intervention_type_3)
      end

      it 'includes those completed in previous years' do
        expect(recent_activity).to include(intervention_type_3)
      end

      it 'returns suggestions from completed action first' do
        expect(recent_activity).to start_with(intervention_type_1)
      end

      it 'returns random from available types' do
        expect(recent_activity[1..]).to match_array([intervention_type_2, intervention_type_3, intervention_type_4])
      end
    end

    context 'with more than limit suggested actions available' do
      let!(:intervention_type_4) { create(:intervention_type, suggested_types: create_list(:intervention_type, 5)) }

      before do
        create(:observation, :intervention, school: school, at: later_this_academic_year, intervention_type: intervention_type_1)
        create(:observation, :intervention, school: school, at: this_academic_year, intervention_type: intervention_type_4)
      end

      it 'returns limit items' do
        expect(recent_activity.count).to eq(5)
      end

      it 'returns suggestions from lastest completed action first' do
        expect(recent_activity).to start_with(intervention_type_1.suggested_types)
      end

      it 'returns last 4 suggestions from next completed action' do
        expect(recent_activity[1..].to_set).to be_subset(intervention_type_4.suggested_types.to_set)
      end
    end

    context 'with no tasks completed' do
      it 'suggests from random' do
        expect(recent_activity).to match_array([intervention_type_1, intervention_type_2, intervention_type_3, intervention_type_4])
      end
    end
  end

  describe '#based_on_energy_use' do
    let(:limit) { 5 }

    subject(:recent_activity) { service.based_on_energy_use(limit) }

    let!(:alert_generation_run) { create(:alert_generation_run, school: school)}
    let!(:alert_type_elec) { create(:alert_type, fuel_type: :electricity)}
    let!(:alert_type_gas) { create(:alert_type, fuel_type: :gas)}

    let!(:intervention_types_elec) { 3.times.collect {|i| create(:intervention_type, name: "elec #{i}") } }
    let!(:intervention_types_gas) { 3.times.collect {|i| create(:intervention_type, name: "gas #{i}") } }

    let!(:alert_type_rating_elec) { create(:alert_type_rating, rating_from: 2.0, rating_to: 6.0, alert_type: alert_type_elec, intervention_types: intervention_types_elec) }
    let!(:alert_type_rating_gas) { create(:alert_type_rating, rating_from: 2.0, rating_to: 6.0, alert_type: alert_type_gas, intervention_types: intervention_types_gas) }

    let(:alert_rating_elec) { 5.0 }

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
      expect(recent_activity).to eq([intervention_types_elec[0], intervention_types_gas[0], intervention_types_elec[1], intervention_types_gas[1], intervention_types_elec[2]])
    end

    context 'when an alert activity has been completed this year' do
      before do
        create(:observation, :intervention, school: school, at: this_academic_year, intervention_type: intervention_types_elec[0])
      end

      it 'does not include activities completed this year' do
        expect(recent_activity).not_to include(intervention_types_elec[0])
      end
    end

    context "when alert rating isn't within alert type rating range" do
      let(:alert_rating_elec) { 1.0 }

      it 'does not include intervention types for alert rating' do
        expect(recent_activity).not_to include(*intervention_types_elec)
      end
    end

    context 'when there is an alert with higher rating' do
      let!(:more_intervention_types_gas) { 3.times.collect {|i| create(:intervention_type, name: "another gas #{i}") } }
      let!(:another_alert_type_gas) { create(:alert_type, fuel_type: :gas)}
      let!(:another_alert_type_rating_gas) { create(:alert_type_rating, rating_from: 1.0, rating_to: 10.0, alert_type: another_alert_type_gas, intervention_types: more_intervention_types_gas) }
      let!(:another_alert_gas) do
        create(:alert,
          alert_generation_run: alert_generation_run,
          alert_type: another_alert_type_gas,
          school: school,
          rating: 2.0
        )
      end

      it 'picks from alert with higher rating' do
        expect(recent_activity).to include(*more_intervention_types_gas)
      end

      it 'includes ratings suggestions alternating by fuel type' do
        expect(recent_activity).to eq([more_intervention_types_gas[0], intervention_types_elec[0], more_intervention_types_gas[1], intervention_types_elec[1], more_intervention_types_gas[2]])
      end
    end

    context 'when there is no alert generation run for school' do
      let(:alert_generation_run) {}

      it { expect(recent_activity).to be_empty }
    end

    context 'when there are no alerts for school' do
      let!(:alert_elec) {}
      let!(:alert_gas) {}

      it { expect(recent_activity).to be_empty }

      context 'when school has suggested actions from an audit' do
        let!(:audit) { create(:audit, school: school, intervention_types: create_list(:intervention_type, 6)) }

        it 'tops up from them' do
          expect(recent_activity).to eq(audit.intervention_types.take(5))
        end

        context 'when one has been recently completed' do
          before do
            create(:observation, :intervention, school: school, at: this_academic_year, intervention_type: audit.intervention_types[0])
          end

          it 'is not included in the results' do
            expect(recent_activity).not_to include(audit.intervention_types[0])
          end
        end
      end
    end
  end
end

require 'rails_helper'

describe Alerts::DeleteAlertGenerationRunService, type: :service do
  let!(:school) { create(:school) }
  let(:service) { Alerts::DeleteAlertGenerationRunService.new }
  let(:alert_type_description) { 'all about this alert type' }
  let(:gas_fuel_alert_type)             { create(:alert_type, fuel_type: :gas, frequency: :termly, description: alert_type_description) }
  let(:electricity_fuel_alert_type)     { create(:alert_type, fuel_type: :electricity, frequency: :termly, description: alert_type_description) }

  it 'defaults to 14 days ago' do
    expect(service.older_than).to eql(14.days.ago.to_date)
  end

  describe '#delete' do
    it 'doesnt delete new runs' do
      date_time = (Time.zone.now - 14.days)
      school.alert_generation_runs.create!(created_at: date_time + 1.day)
      school.alert_generation_runs.create!(created_at: date_time + 1.week)
      school.alert_generation_runs.create!(created_at: Time.zone.now)
      expect { service.delete! }.not_to change(AlertGenerationRun, :count)
    end

    context 'when there are older runs to delete' do
      it 'deletes only the older runs' do
        school.alert_generation_runs.create!(created_at: Time.zone.now)
        school.alert_generation_runs.create!(created_at: Time.zone.now - 13.days)
        school.alert_generation_runs.create!(created_at: Time.zone.now - 1.month)
        school.alert_generation_runs.create!(created_at: Time.zone.now - 3.months)
        expect(AlertGenerationRun.count).to eq 4
        expect { service.delete! }.to change(AlertGenerationRun, :count).from(4).to(2)
      end

      it 'deletes all of the dependent objects' do
        date_time = (Time.zone.now - 1.month)
        alert_generation_run = school.alert_generation_runs.create!(created_at: date_time)
        create(:alert, school: school, alert_type: gas_fuel_alert_type, created_at: date_time, alert_generation_run: alert_generation_run)
        create(:alert, school: school, alert_type: electricity_fuel_alert_type, created_at: date_time, alert_generation_run: alert_generation_run)
        create(:alert_error, alert_type: gas_fuel_alert_type, created_at: date_time, alert_generation_run: alert_generation_run)
        create(:alert_error, alert_type: electricity_fuel_alert_type, created_at: date_time, alert_generation_run: alert_generation_run)
        expect(AlertGenerationRun.count).to eq 1
        expect(AlertGenerationRun.first.alerts.count).to eq 2
        expect(AlertGenerationRun.first.alert_errors.count).to eq 2
        expect(Alert.count).to eq 2
        expect(AlertError.count).to eq 2
        expect { service.delete! }.to change(AlertGenerationRun, :count).from(1).to(0) &
                                      change(Alert, :count).from(2).to(0) &
                                      change(AlertError, :count).from(2).to(0)
      end
    end
  end
end

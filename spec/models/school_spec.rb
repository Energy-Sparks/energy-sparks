require 'rails_helper'

describe School do

  let(:today) { Time.zone.today }
  let(:calendar) { create :calendar, template: true }
  subject { create :school, :with_school_group, calendar: calendar }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'builds a slug on create using :name' do
    expect(subject.slug).to eq(subject.name.parameterize)
  end

  describe 'FriendlyID#slug_candidates' do
    context 'when two schools have the same name' do
      it 'builds a different slug using :postcode and :name' do
        school = (create_list :school_with_same_name, 2).last
        expect(school.slug).to eq([school.postcode, school.name].join('-').parameterize)
      end
    end
    context 'when three schools have the same name and postcode' do
      it 'builds a different slug using :urn and :name' do
        school = (create_list :school_with_same_name, 3).last
        expect(school.slug).to eq([school.urn, school.name].join('-').parameterize)
      end
    end
  end

  describe '#meters?' do
    context 'when the school has meters of type :gas' do
      it 'returns true' do
        create :gas_meter_with_reading, school_id: subject.id
        expect(subject.meters?(:gas)).to be(true)
      end
    end
    context 'when the school has no meters' do
      it 'returns false' do
        expect(subject.meters?(:gas)).to be(false)
      end
    end
  end

  describe '#current_term' do

    it 'returns the current term' do
      current_term = create :term, calendar_id: subject.calendar_id, start_date: today.months_ago(3), end_date: today.tomorrow
      expect(subject.current_term).to eq(current_term)
    end
  end

  describe '#last_term' do

    it 'returns the term preceeding #current_term' do
      create :term, calendar_id: subject.calendar_id, start_date: today.months_ago(3), end_date: today.tomorrow
      last_term = create :term, calendar_id: subject.calendar_id, start_date: today.months_ago(6), end_date: today.yesterday.months_ago(3)

      expect(subject.last_term).to eq(last_term)
    end
  end

  describe '#fuel_types' do
    it 'identifies dual fuel if it has both meters' do
      gas_meter = create(:gas_meter_with_reading, school: subject)
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      expect(subject.fuel_types).to eq :electric_and_gas
    end

    it 'identifies electricity if it has electricity only' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      expect(subject.fuel_types).to eq :electric_only
    end

    it 'identifies gas if it has gas only' do
      gas_meter = create(:gas_meter_with_reading, school: subject)
      expect(subject.fuel_types).to eq :gas_only
    end

    it 'identifies gas if it has gas only with no readings for electricity' do
      electricity_meter = create(:electricity_meter, school: subject)
      gas_meter = create(:gas_meter_with_reading, school: subject)
      expect(subject.fuel_types).to eq :gas_only
    end

    it 'identifies gas if it has gas only with readings and one without and no readings for electricity' do
      electricity_meter = create(:electricity_meter, school: subject)
      gas_meter = create(:gas_meter_with_reading, school: subject)
      gas_meter_no_readings = create(:gas_meter, school: subject)
      expect(subject.fuel_types).to eq :gas_only
    end

    it 'identifies electricity if it has an electricity with readings and with no readings for gas' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      gas_meter = create(:gas_meter, school: subject)
      expect(subject.fuel_types).to eq :electric_only
    end

    it 'identifies electricity if it has an electricity with readings and one without and with no readings for gas' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      electricity_meter_no_readings = create(:electricity_meter, school: subject)
      gas_meter = create(:gas_meter, school: subject)
      expect(subject.fuel_types).to eq :electric_only
    end
  end

  describe '#meters_with_readings' do
    it 'works if explicitly giving a supply type of electricity' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      expect(subject.meters_with_readings(:electricity).first).to eq electricity_meter
      expect(subject.meters_with_readings(:gas)).to be_empty
    end

    it 'works if explicitly giving a supply type of gas' do
      gas_meter = create(:gas_meter_with_reading, school: subject)
      expect(subject.meters_with_readings(:gas).first).to eq gas_meter
      expect(subject.meters_with_readings(:electricity)).to be_empty
    end

    it 'works without a supply type for a gas meter' do
      gas_meter = create(:gas_meter_with_reading, school: subject)
      expect(subject.meters_with_readings.first).to eq gas_meter
    end

    it 'works without a supply type for an electricity' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      expect(subject.meters_with_readings.first).to eq electricity_meter
    end
  end

  describe '#meters_with_validated_readings' do
    it 'works if explicitly giving a supply type of electricity' do
      electricity_meter = create(:electricity_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings(:electricity).first).to eq electricity_meter
      expect(subject.meters_with_validated_readings(:gas)).to be_empty
    end

    it 'works if explicitly giving a supply type of gas' do
      gas_meter = create(:gas_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings(:gas).first).to eq gas_meter
      expect(subject.meters_with_validated_readings(:electricity)).to be_empty
    end

    it 'works without a supply type for a gas meter' do
      gas_meter = create(:gas_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings.first).to eq gas_meter
    end

    it 'works without a supply type for an electricity' do
      electricity_meter = create(:electricity_meter_with_validated_reading, school: subject)
      expect(subject.meters_with_validated_readings.first).to eq electricity_meter
    end
  end

  describe '#scoreboard_position' do
    let!(:scoreboard)       { create :scoreboard }
    let!(:group)            { create(:school_group, scoreboard: scoreboard) }
    let!(:pointy_school)    { create :school, :with_points, score_points: 6, school_group: group }

    it "knows it's position in it's scoreboard" do
      expect(pointy_school.scoreboard_position).to be 1
    end
  end

  describe '#latest_dashboard_alerts' do
    let(:school){ create :school }
    let(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity, frequency: :termly) }
    let(:alert_type_rating){ create(:alert_type_rating, alert_type: electricity_fuel_alert_type) }

    let(:content_version_1){ create(:alert_type_rating_content_version, alert_type_rating: alert_type_rating)}
    let(:alert_1){ create(:alert, alert_type: electricity_fuel_alert_type) }
    let(:alert_2){ create(:alert, alert_type: electricity_fuel_alert_type) }
    let(:content_generation_run_1){ create(:content_generation_run, school: school, created_at: 1.day.ago)}
    let(:content_generation_run_2){ create(:content_generation_run, school: school, created_at: Date.today)}

    context 'where there is a content run' do

      let!(:dashboard_alert_1){ create(:dashboard_alert, alert: alert_1, content_version: content_version_1, content_generation_run: content_generation_run_1) }
      let!(:dashboard_alert_2){ create(:dashboard_alert, alert: alert_1, content_version: content_version_1, content_generation_run: content_generation_run_2) }

      it 'selects the dashboard alerts from the most recent run' do
        expect(school.latest_dashboard_alerts).to match_array([dashboard_alert_2])
      end
    end

    context 'where there is no run' do
      it 'returns an empty set' do
        expect(school.latest_dashboard_alerts).to be_empty
      end
    end

  end
end

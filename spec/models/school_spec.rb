require 'rails_helper'

describe School do

  let(:today) { Time.zone.today }
  let(:calendar) { create :calendar }
  subject { create :school, :with_school_group, calendar: calendar }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'builds a slug on create using :name' do
    expect(subject.slug).to eq(subject.name.parameterize)
  end

  describe '#minimum_readings_date' do
    it 'returns the minimum amr validated readings date minus 1 year if amr_validated_readings are present' do
      meter = create(:electricity_meter, school: subject)
      base_date = Date.today - 1.years
      create(:amr_validated_reading, meter: meter, reading_date: base_date)
      create(:amr_validated_reading, meter: meter, reading_date: base_date + 2.days)
      create(:amr_validated_reading, meter: meter, reading_date: base_date + 4.days)

      expect(subject.minimum_readings_date).to eq(base_date - 1.year)
    end

    it 'returns nil if amr_validated_readings are not present' do

      expect(subject.minimum_readings_date).to eq(nil)
    end
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

  describe '#fuel_types' do
    it 'identifies dual fuel if it has both meters' do
      fuel_configuration = Schools::FuelConfiguration.new(has_gas: true, has_electricity: true)
      subject.configuration.update(fuel_configuration: fuel_configuration)
      expect(subject.fuel_types).to eq :electric_and_gas
    end

    it 'identifies electricity if it has electricity only' do
      fuel_configuration = Schools::FuelConfiguration.new(has_gas: false, has_electricity: true)
      subject.configuration.update(fuel_configuration: fuel_configuration)
      expect(subject.fuel_types).to eq :electric_only
    end

    it 'identifies gas if it has gas only' do
      fuel_configuration = Schools::FuelConfiguration.new(has_gas: true, has_electricity: false)
      subject.configuration.update(fuel_configuration: fuel_configuration)
      expect(subject.fuel_types).to eq :gas_only
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

    it 'ignores deactivated meters' do
      electricity_meter = create(:electricity_meter_with_reading, school: subject)
      electricity_meter_inactive = create(:electricity_meter_with_reading, school: subject, active: false)
      expect(subject.meters_with_readings(:electricity)).to match_array([electricity_meter])
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

    it 'ignores deactivated meters' do
      electricity_meter = create(:electricity_meter_with_validated_reading, school: subject)
      electricity_meter_inactive = create(:electricity_meter_with_validated_reading, school: subject, active: false)
      expect(subject.meters_with_validated_readings(:electricity)).to match_array([electricity_meter])
    end
  end

  describe '#latest_alerts_without_exclusions' do
    let(:school){ create :school }
    let(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity, frequency: :termly) }


    context 'where there is an alert run' do

      let(:alert_generation_run_1){ create(:alert_generation_run, school: school, created_at: 1.day.ago)}
      let(:alert_generation_run_2){ create(:alert_generation_run, school: school, created_at: Date.today)}

      let!(:alert_1){ create(:alert, alert_type: electricity_fuel_alert_type, school: school, alert_generation_run: alert_generation_run_1) }
      let!(:alert_2){ create(:alert, alert_type: electricity_fuel_alert_type, school: school, alert_generation_run: alert_generation_run_2) }

      it 'selects the dashboard alerts from the most recent run' do
        expect(school.latest_alerts_without_exclusions).to match_array([alert_2])
      end
    end

    context 'where there is no run' do
      it 'returns an empty set' do
        expect(school.latest_alerts_without_exclusions).to be_empty
      end
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

  describe 'authenticate_pupil' do

    let(:school){ create :school }
    let!(:pupil){ create :pupil, pupil_password: 'testTest', school: school }

    it 'selects pupils with the correct password' do
      expect(school.authenticate_pupil('testTest')).to eq(pupil)
    end

    it 'returns nothing if the password does not match' do
      expect(school.authenticate_pupil('barp')).to eq(nil)
    end

    it 'is not case sensitive' do
      expect(school.authenticate_pupil('testtest')).to eq(pupil)
    end
  end

  describe 'process_data!' do

    it 'errors when the school has no meters with readings' do
      school = create(:school, process_data: false)
      expect{
        school.process_data!
      }.to raise_error(School::ProcessDataError, /has no meter readings/)
      expect(school.process_data).to eq(false)
    end

    it 'errors when the school has no floor area' do
      school = create(:school, process_data: false, floor_area: nil)
      electricity_meter = create(:electricity_meter_with_reading, school: school)
      expect{
        school.process_data!
      }.to raise_error(School::ProcessDataError, /has no floor area/)
      expect(school.process_data).to eq(false)
    end

    it 'errors when the school has no pupil numbers' do
      school = create(:school, process_data: false, number_of_pupils: nil)
      electricity_meter = create(:electricity_meter_with_reading, school: school)
      expect{
        school.process_data!
      }.to raise_error(School::ProcessDataError, /has no pupil numbers/)
      expect(school.process_data).to eq(false)
    end

    it 'does not error when the school has floor area, pupil numbers and a meter' do
      school = create(:school, process_data: false)
      electricity_meter = create(:electricity_meter_with_reading, school: school)
      expect{
        school.process_data!
      }.to_not raise_error
      expect(school.process_data).to eq(true)
    end
  end

  describe 'geolocation' do
    it 'the school is geolocated on creation' do
      school = create(:school, latitude: nil, longitude: nil)
      expect(school.latitude).to_not be nil
      expect(school.longitude).to_not be nil
    end

    it 'the school is geolocated if the postcode is changed' do
      school = create(:school)
      school.update(latitude: nil, longitude: nil)
      school.reload

      expect(school.latitude).to be nil
      expect(school.longitude).to be nil

      school.update(postcode: 'B')
      school.reload

      expect(school.latitude).to_not be nil
      expect(school.longitude).to_not be nil
    end
  end

  context 'with partners' do
    let(:partner)       { create(:partner) }
    let(:other_partner) { create(:partner) }

    it "can add a partner" do
      expect(SchoolPartner.count).to eql(0)
      subject.partners << partner
      expect(SchoolPartner.count).to eql(1)
    end

    it "orders partners by position" do
      SchoolPartner.create(school: subject, partner: partner, position: 1)
      SchoolPartner.create(school: subject, partner: other_partner, position: 0)
      expect(subject.partners.first).to eql(other_partner)
      expect(subject.partners).to match_array([other_partner, partner])
    end

    it "finds all partners" do
      expect(subject.all_partners).to match([])
      subject.partners << partner
      expect(subject.all_partners).to match([partner])
      subject.school_group.partners << other_partner
      expect(subject.all_partners).to match([partner, other_partner])
      subject.partners.destroy_all
      expect(subject.all_partners).to match([other_partner])
    end
  end

  context 'with consent' do
    let!(:consent_statement)    { create(:consent_statement, current: true) }

    it "identifies whether consent is current" do
      expect(subject.consent_up_to_date?).to be false
      create(:consent_grant, school: subject)
      expect(subject.consent_up_to_date?).to be false
      create(:consent_grant, school: subject, consent_statement: consent_statement)
      expect(subject.consent_up_to_date?).to be true
    end
  end

  context 'checking abilities' do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }

    let!(:school_group) { create(:school_group, name: 'School Group')}
    let!(:other_school) { create(:school, name: 'Other School', visible: true, school_group: school_group)}

    context 'Schools that are not visible' do
      let!(:school)       { create(:school, name: 'School', visible: false, school_group: school_group)}

      it 'disallows guest access' do
        expect(ability).to_not be_able_to(:show, school)
        expect(ability).to_not be_able_to(:show_pupils_dash, school)
        expect(ability).to_not be_able_to(:show_management_dash, school)
        expect(ability).to_not be_able_to(:read_restricted_analysis, school)
      end

      context "as school admin" do
        let!(:user)          { create(:school_admin, school: school) }

        it 'disallows access' do
          expect(ability).to_not be_able_to(:show, school)
          expect(ability).to_not be_able_to(:show_pupils_dash, school)
          expect(ability).to_not be_able_to(:show_management_dash, school)
          expect(ability).to_not be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as admin" do
        let(:user) { create(:admin) }

        it "can do anything" do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to be_able_to(:read_restricted_analysis, school)
        end
      end

    end

    context 'Schools that are visible' do
      let!(:school)       { create(:school, name: 'School', visible: true, school_group: school_group)}

      it 'disallows guest access' do
        expect(ability).to be_able_to(:show, school)
        expect(ability).to be_able_to(:show_pupils_dash, school)
        expect(ability).to_not be_able_to(:show_management_dash, school)

        expect(ability).to_not be_able_to(:read_restricted_analysis, school)
      end

      context "as school admin" do
        let!(:user)          { create(:school_admin, school: school) }

        it 'disallows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as related school admin" do
        let!(:user)          { create(:school_admin, school: other_school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to_not be_able_to(:show_management_dash, school)
          expect(ability).to_not be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as admin" do
        let(:user) { create(:admin) }

        it "can do anything" do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to be_able_to(:read_restricted_analysis, school)
        end
      end

    end

    context 'Schools that are not public' do
      let!(:school)       { create(:school, name: 'School', visible: true, public: false, school_group: school_group)}

      it 'disallows guest access' do
        expect(ability).to_not be_able_to(:show, school)
        expect(ability).to_not be_able_to(:show_pupils_dash, school)
        expect(ability).to_not be_able_to(:show_management_dash, school)
        expect(ability).to_not be_able_to(:read_restricted_analysis, school)
      end

      context "as school admin" do
        let!(:user)          { create(:school_admin, school: school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as teacher" do
        let!(:user)          { create(:staff, school: school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as pupil" do
        let!(:user)          { create(:pupil, school: school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to_not be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as related school admin" do
        let!(:user)          { create(:school_admin, school: other_school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to_not be_able_to(:show_management_dash, school)
          expect(ability).to_not be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as teacher from school in same group" do
        let!(:user)          { create(:staff, school: other_school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to_not be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as pupil from school in same group" do
        let!(:user)          { create(:pupil, school: other_school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to_not be_able_to(:read_restricted_analysis, school)
        end

      end

      context "as admin" do
        let(:user) { create(:admin) }

        it "can do anything" do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to be_able_to(:read_restricted_analysis, school)
        end
      end

    end


  end

  context 'with live data' do
    let(:cad) { create(:cad, school: subject, active: true) }
    it "checks for presence of active cads" do
      expect(subject.has_live_data?).to be false
      subject.cads << cad
      expect(subject.has_live_data?).to be true
      cad.update(active: false)
      expect(subject.has_live_data?).to be false
    end
  end

  context 'with annual estimates' do

    it "there are no meter attributes without an estimate" do
      expect(subject.estimated_annual_consumption_meter_attributes).to eql({})
      expect(subject.all_pseudo_meter_attributes).to eql({})
    end

    context "when an estimate is given" do
      let!(:estimate)  { create(:estimated_annual_consumption, school: subject, electricity: 1000.0, gas: 1500.0, storage_heaters: 500.0, year: 2021) }

      before(:each) do
        subject.reload
      end

      it "the target should add meter attributes" do
        expect(subject.all_pseudo_meter_attributes).to_not eql({})
      end

    end
  end

  context 'with school targets' do

    it "there is no target by default" do
      expect(subject.has_target?).to be false
      expect(subject.current_target).to be nil
    end

    it "there are no meter attributes without a target" do
      expect(subject.school_target_attributes).to eql({})
      expect(subject.all_pseudo_meter_attributes).to eql({})
    end

    context "when a target is set" do
      let!(:target) { create(:school_target, start_date: Date.yesterday, school: subject) }

      before(:each) do
        subject.reload
      end

      it "should find the target" do
        expect(subject.has_target?).to be true
        expect(subject.has_current_target?).to eql true
        expect(subject.current_target).to eql target
        expect(subject.most_recent_target).to eql target
      end

      it "the target should add meter attributes" do
        expect(subject.all_pseudo_meter_attributes).to_not eql({})
      end

      context "with multiple targets" do
        let!(:future_target) { create(:school_target, start_date: Date.tomorrow, school: subject) }

        it "should find the current target" do
          expect(subject.has_target?).to be true
          expect(subject.has_current_target?).to be true
          expect(subject.current_target).to eql target
          expect(subject.most_recent_target).to eql future_target
        end
      end

      context "with expired target" do
        before(:each) do
          target.update!(start_date: Date.yesterday.prev_year)
        end

        it "should find the expired target" do
          expect(subject.has_target?).to be true
          expect(subject.has_current_target?).to be false
          expect(subject.current_target).to eql nil
          expect(subject.most_recent_target).to eql target
        end

        it "should still produce meter attributes" do
          expect(subject.all_pseudo_meter_attributes).to_not eql({})
        end
      end
    end
  end

  context 'school users' do
    let!(:school_admin)     { create(:school_admin, school: subject)}
    let!(:cluster_admin)    { create(:school_admin, name: "Cluster admin", cluster_schools: [subject]) }
    let!(:staff)            { create(:staff, school: subject)}
    let!(:pupil)            { create(:pupil, school: subject)}

    it 'identifies different groups' do
      expect(subject.school_admin).to match_array([school_admin])
      expect(subject.cluster_users).to match_array([cluster_admin])
      expect(subject.staff).to match_array([staff])
      expect(subject.all_school_admins).to match_array([school_admin, cluster_admin])
      expect(subject.all_adult_school_users).to match_array([school_admin, cluster_admin, staff])
    end

    it 'handles empty lists' do
      school = create(:school)
      expect(school.school_admin).to be_empty
      expect(school.cluster_users).to be_empty
      expect(school.staff).to be_empty
      expect(school.all_school_admins).to be_empty
      expect(school.all_adult_school_users).to be_empty

      new_admin = create(:school_admin, school: school)
      expect(school.all_school_admins).to match_array([new_admin])
      expect(school.all_adult_school_users).to match_array([new_admin])
    end
  end

  context '#awaiting_activation' do
    let(:school){ create :school, visible: true, data_enabled: true }

    it 'returns expected lists' do
      expect(School.awaiting_activation).to be_empty
      school.update!(visible: false)
      expect(School.awaiting_activation).to match_array([school])
      school.update!(visible: true, data_enabled: false)
      expect(School.awaiting_activation).to match_array([school])
    end
  end

  context 'with school times' do
    let(:school){ create :school, visible: true, data_enabled: true }

    let!(:school_day) { create(:school_time, school: school, day: :tuesday, usage_type: :school_day, opening_time: 815, closing_time: 1520)}

    let!(:community_use) { create(:school_time, school: school, day: :monday, usage_type: :community_use, opening_time: 1800, closing_time: 2030)}

    it 'serialises school day' do
      times = school.school_times_to_analytics
      expect(times.length).to eq 1
      expect(times[0][:day]).to eql :tuesday
    end
    it 'serialises community_use' do
      times = school.community_use_times_to_analytics
      expect(times.length).to eq 1
      expect(times[0][:day]).to eql :monday
    end
  end

  describe 'with activities' do
    let(:calendar){ create :school_calendar }
    let(:academic_year){ calendar.academic_years.last }
    let(:school){ create :school, calendar: calendar }
    let(:date_1){ academic_year.start_date + 1.month}
    let(:date_2){ academic_year.start_date - 1.month}
    let!(:activity_1){ create :activity, happened_on: date_1, school: school }
    let!(:activity_2){ create :activity, happened_on: date_2, school: school }

    it 'finds activities from the academic year' do
      expect(school.activities_in_academic_year(academic_year.start_date + 2.months)).to eq([activity_1])
    end
  end

  describe 'with actions' do
    let(:calendar){ create :school_calendar }
    let(:academic_year){ calendar.academic_years.last }
    let(:school){ create :school, calendar: calendar }
    let(:date_1){ academic_year.start_date + 1.month}
    let(:date_2){ academic_year.start_date - 1.month}
    let!(:intervention_type_1){ create :intervention_type }
    let!(:intervention_type_2){ create :intervention_type }
    let!(:observation_1){ create :observation, :intervention, at: date_1, school: school, intervention_type: intervention_type_1 }
    let!(:observation_2){ create :observation, :intervention, at: date_2, school: school, intervention_type: intervention_type_2 }
    let!(:observation_without_intervention_type) { create(:observation, :temperature, at: date_1, school: school) }

    it 'finds observations from the academic year' do
      expect(school.observations_in_academic_year(academic_year.start_date + 2.months)).to eq([observation_1, observation_without_intervention_type])
    end

    it 'handles missing academic year' do
      expect(school.observations_in_academic_year(Date.parse('01-01-1900'))).to eq([])
    end

    it 'finds intervention types from the academic year' do
      expect(school.intervention_types_in_academic_year(academic_year.start_date + 2.months)).to eq([intervention_type_1])
    end

    it 'handles missing academic year' do
      expect(school.intervention_types_in_academic_year(Date.parse('01-01-1900'))).to eq([])
    end

    context 'when finding intervention types by date' do
      let!(:recent_observation)  { create(:observation, :intervention, at: date_1 + 1.day, school: school, intervention_type: intervention_type_2) }
      it 'finds intervention types by date, including duplicates, excluding non-intervention observations' do
        expect(school.intervention_types_by_date).to eq([intervention_type_2, intervention_type_1, intervention_type_2])
      end
    end
  end
end

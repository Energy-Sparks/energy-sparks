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

  describe '#with_energy_tariffs' do
    let(:school_1) { create(:school) }
    let(:school_2) { create(:school) }
    let(:school_group) { create(:school_group) }

    it 'returns only schools with associated energy tariffs' do
      [school_1, school_group, SiteSettings.current].each do |tariff_holder|
        EnergyTariff.create(
          tariff_holder: tariff_holder,
          start_date: '2021-04-01',
          end_date: '2022-03-31',
          name: 'My First Tariff',
          meter_type: :electricity
        )
      end
      expect(School.all).to match_array([school_1, school_2])
      expect(School.with_energy_tariffs).to eq([school_1])
    end
  end

  describe '#minimum_reading_date' do
    it 'returns the minimum amr validated readings date minus 1 year if amr_validated_readings are present' do
      meter = create(:electricity_meter, school: subject)
      meter2 = create(:electricity_meter, school: subject)
      meter3 = create(:electricity_meter, school: subject)

      base_date = Time.zone.today - 1.year
      create(:amr_validated_reading, meter: meter, reading_date: base_date)
      create(:amr_validated_reading, meter: meter, reading_date: base_date + 2.days)
      create(:amr_validated_reading, meter: meter, reading_date: base_date + 4.days)
      create(:amr_validated_reading, meter: meter2, reading_date: base_date + 1.day)
      create(:amr_validated_reading, meter: meter2, reading_date: base_date + 2.days)
      create(:amr_validated_reading, meter: meter3, reading_date: base_date + 6.days)

      expect(subject.minimum_reading_date).to eq(base_date - 1.year)
      expect(subject.minimum_reading_date).to eq(AmrValidatedReading.where(meter_id: meter.id).minimum(:reading_date) - 1.year)
    end

    it 'returns nil if amr_validated_readings are not present' do
      expect(subject.minimum_reading_date).to eq(nil)
    end
  end

  it 'validates alternative heating percents' do
    [:alternative_heating_oil_percent, :alternative_heating_lpg_percent, :alternative_heating_biomass_percent, :alternative_heating_district_heating_percent].each do |field|
      subject[field] = 100
      expect(subject).to be_valid
      subject[field] = 0
      expect(subject).to be_valid
      subject[field] = -1
      expect(subject).not_to be_valid
      subject[field] = 101
      expect(subject).not_to be_valid
      subject[field] = nil
      expect(subject).to be_valid
    end
  end

  it 'validates postcodes' do
    ["BA2 £3Z", "BA14 9 DU", "TS11 7B"].each do |invalid|
      subject.postcode = invalid
      expect(subject).to_not be_valid
    end
    ["OL84JZ", "OL8 4JZ"].each do |valid|
      subject.postcode = valid
      expect(subject).to be_valid
    end
  end

  it 'validates free school meals' do
    [-1, 200].each do |invalid|
      subject.percentage_free_school_meals = invalid
      expect(subject).to_not be_valid
    end
    subject.percentage_free_school_meals = 20
    expect(subject).to be_valid
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
      electricity_meter = create(:electricity_meter_with_reading, reading_count: 10, school: subject)
      expect(subject.meters_with_readings(:electricity).first).to eq electricity_meter
      expect(subject.meters_with_readings(:gas)).to be_empty
    end

    it 'works if explicitly giving a supply type of gas' do
      gas_meter = create(:gas_meter_with_reading, reading_count: 10, school: subject)
      expect(subject.meters_with_readings(:gas).first).to eq gas_meter
      expect(subject.meters_with_readings(:electricity)).to be_empty
    end

    it 'works without a supply type for a gas meter' do
      gas_meter = create(:gas_meter_with_reading, reading_count: 10, school: subject)
      expect(subject.meters_with_readings.first).to eq gas_meter
    end

    it 'works without a supply type for an electricity' do
      electricity_meter = create(:electricity_meter_with_reading, reading_count: 10, school: subject)
      expect(subject.meters_with_readings.first).to eq electricity_meter
    end

    it 'ignores deactivated meters' do
      electricity_meter = create(:electricity_meter_with_reading, reading_count: 10, school: subject)
      create(:electricity_meter_with_reading, reading_count: 10, school: subject, active: false)
      expect(subject.meters_with_readings(:electricity)).to match_array([electricity_meter])
    end
  end

  describe '#meters_with_validated_readings' do
    it 'works if explicitly giving a supply type of electricity' do
      electricity_meter = create(:electricity_meter_with_validated_reading, reading_count: 10, school: subject)
      expect(subject.meters_with_validated_readings(:electricity).first).to eq electricity_meter
      expect(subject.meters_with_validated_readings(:gas)).to be_empty
    end

    it 'works if explicitly giving a supply type of gas' do
      gas_meter = create(:gas_meter_with_validated_reading, reading_count: 10, school: subject)
      expect(subject.meters_with_validated_readings(:gas).first).to eq gas_meter
      expect(subject.meters_with_validated_readings(:electricity)).to be_empty
    end

    it 'works without a supply type for a gas meter' do
      gas_meter = create(:gas_meter_with_validated_reading, reading_count: 10, school: subject)
      expect(subject.meters_with_validated_readings.first).to eq gas_meter
    end

    it 'works without a supply type for an electricity' do
      electricity_meter = create(:electricity_meter_with_validated_reading, reading_count: 10, school: subject)
      expect(subject.meters_with_validated_readings.first).to eq electricity_meter
    end

    it 'ignores deactivated meters' do
      electricity_meter = create(:electricity_meter_with_validated_reading, reading_count: 10, school: subject)
      create(:electricity_meter_with_validated_reading, school: subject, active: false)
      expect(subject.meters_with_validated_readings(:electricity)).to match_array([electricity_meter])
    end
  end

  describe '#latest_alerts_without_exclusions' do
    let(:school) { create :school }
    let(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity, frequency: :termly) }


    context 'where there is an alert run' do
      let(:alert_generation_run_1) { create(:alert_generation_run, school: school, created_at: 1.day.ago)}
      let(:alert_generation_run_2) { create(:alert_generation_run, school: school, created_at: Time.zone.today)}

      let!(:alert_1) { create(:alert, alert_type: electricity_fuel_alert_type, school: school, alert_generation_run: alert_generation_run_1) }
      let!(:alert_2) { create(:alert, alert_type: electricity_fuel_alert_type, school: school, alert_generation_run: alert_generation_run_2) }

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
    let(:school) { create :school }
    let(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity, frequency: :termly) }
    let(:alert_type_rating) { create(:alert_type_rating, alert_type: electricity_fuel_alert_type) }

    let(:content_version_1) { create(:alert_type_rating_content_version, alert_type_rating: alert_type_rating)}
    let(:alert_1) { create(:alert, alert_type: electricity_fuel_alert_type) }
    let(:alert_2) { create(:alert, alert_type: electricity_fuel_alert_type) }
    let(:content_generation_run_1) { create(:content_generation_run, school: school, created_at: 1.day.ago)}
    let(:content_generation_run_2) { create(:content_generation_run, school: school, created_at: Time.zone.today)}

    context 'where there is a content run' do
      let!(:dashboard_alert_1) { create(:dashboard_alert, alert: alert_1, content_version: content_version_1, content_generation_run: content_generation_run_1) }
      let!(:dashboard_alert_2) { create(:dashboard_alert, alert: alert_1, content_version: content_version_1, content_generation_run: content_generation_run_2) }

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
    let(:school) { create :school }
    let!(:pupil) { create :pupil, pupil_password: 'testTest', school: school }

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
      expect do
        school.process_data!
      end.to raise_error(School::ProcessDataError, /has no meter readings/)
      expect(school.process_data).to eq(false)
    end

    it 'errors when the school has no floor area' do
      school = create(:school, process_data: false, floor_area: nil)
      create(:electricity_meter_with_reading, school: school)
      expect do
        school.process_data!
      end.to raise_error(School::ProcessDataError, /has no floor area/)
      expect(school.process_data).to eq(false)
    end

    it 'errors when the school has no pupil numbers' do
      school = create(:school, process_data: false, number_of_pupils: nil)
      create(:electricity_meter_with_reading, school: school)
      expect do
        school.process_data!
      end.to raise_error(School::ProcessDataError, /has no pupil numbers/)
      expect(school.process_data).to eq(false)
    end

    it 'does not error when the school has floor area, pupil numbers and a meter' do
      school = create(:school, process_data: false)
      create(:electricity_meter_with_reading, school: school)
      expect do
        school.process_data!
      end.to_not raise_error
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
      school.update(latitude: 55.952221, longitude: -3.174625, country: 'scotland')
      school.reload

      expect(school.latitude).to eq(55.952221)
      expect(school.longitude).to eq(-3.174625)
      expect(school.country).to eq('scotland')

      school.update(postcode: "OL8 4JZ")
      school.reload

      # values from default stub on Geocoder::Lookup::Test
      expect(school.latitude).to eq(51.340620)
      expect(school.longitude).to eq(-2.301420)
      expect(school.country).to eq('england')
    end

    it 'passes validation with a findable postcode' do
      school = build(:school, postcode: 'EH99 1SP')
      expect(school.valid?).to eq(true)
      expect(school.errors.messages).to eq({})
      expect(school.latitude).to eq(55.952221)
      expect(school.longitude).to eq(-3.174625)
      expect(school.country).to eq('scotland')
    end

    it 'fails validation with a non findable postcode' do
      school = build(:school, postcode: 'EH99 2SP')
      expect(school.valid?).to eq(false)
      expect(school.errors.messages[:postcode]).to eq(['not found.'])
      expect(school.latitude).to eq(nil)
      expect(school.longitude).to eq(nil)
      expect(school.country).to eq(nil)
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
    let!(:consent_statement) { create(:consent_statement, current: true) }

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
        let!(:user) { create(:school_admin, school: school) }

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
        let!(:user) { create(:school_admin, school: school) }

        it 'disallows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as related school admin" do
        let!(:user) { create(:school_admin, school: other_school) }

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
        let!(:user) { create(:school_admin, school: school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as teacher" do
        let!(:user) { create(:staff, school: school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as pupil" do
        let!(:user) { create(:pupil, school: school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
          expect(ability).to_not be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as related school admin" do
        let!(:user) { create(:school_admin, school: other_school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to_not be_able_to(:show_management_dash, school)
          expect(ability).to_not be_able_to(:read_restricted_analysis, school)
        end
      end

      context "as teacher from school in same group" do
        let!(:user) { create(:staff, school: other_school) }

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
      let!(:estimate) { create(:estimated_annual_consumption, school: subject, electricity: 1000.0, gas: 1500.0, storage_heaters: 500.0, year: 2021) }

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
        expect(subject.expired_target).to be_nil
        expect(subject.has_expired_target?).to eql false
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
          expect(subject.expired_target).to be_nil
          expect(subject.has_expired_target?).to eql false
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
          expect(subject.expired_target).to eq target
          expect(subject.has_expired_target?).to eql true
        end

        it "should still produce meter attributes" do
          expect(subject.all_pseudo_meter_attributes).to_not eql({})
        end
      end

      describe "#has_expired_target_for_fuel_type?" do
        before(:each) do
          target.update!(electricity: 5)
        end
        let!(:expired_target) { create(:school_target, start_date: Date.yesterday.prev_year, school: subject, electricity: 5, gas: nil) }
        it { expect(subject.has_expired_target_for_fuel_type?(:electricity)).to be true }
        it { expect(subject.has_expired_target_for_fuel_type?(:gas)).to be false }
      end

      describe "#previous_expired_target" do
        let!(:expired_target) { create(:school_target, start_date: Date.yesterday.prev_year, school: subject) }
        let!(:older_expired_target) { create(:school_target, start_date: Date.yesterday.years_ago(2), school: subject) }
        let!(:oldest_expired_target) { create(:school_target, start_date: Date.yesterday.years_ago(3), school: subject) }

        it { expect(subject.previous_expired_target(expired_target)).to eq older_expired_target }
        it { expect(subject.previous_expired_target(older_expired_target)).to eq oldest_expired_target }
        it { expect(subject.previous_expired_target(oldest_expired_target)).to be_nil }
        it { expect(subject.previous_expired_target(nil)).to be_nil }
        it { expect(subject.previous_expired_target(target)).to be_nil }
      end
    end
  end

  context 'school users' do
    let!(:school_admin)     { create(:school_admin, school: subject, email: 'school_user_1@test.com')}
    let!(:cluster_admin)    { create(:school_admin, name: "Cluster admin", cluster_schools: [subject], email: 'school_user_2@test.com') }
    let!(:staff)            { create(:staff, school: subject, email: 'school_user_3@test.com')}
    let!(:staff_2)          { create(:staff, school: subject, cluster_schools: [subject], email: 'school_user_4@test.com') }
    let!(:pupil)            { create(:pupil, school: subject, email: 'school_user_5@test.com')}

    it 'identifies different groups' do
      expect(subject.school_admin).to match_array([school_admin])
      expect(subject.cluster_users).to match_array([cluster_admin, staff_2])
      expect(subject.staff).to match_array([staff, staff_2])
      expect(subject.all_school_admins.sort { |a, b| a.email <=> b.email }).to match_array([staff_2, school_admin, cluster_admin].sort { |a, b| a.email <=> b.email })
      expect((subject.all_school_admins + subject.staff).sort { |a, b| a.email <=> b.email }).to match_array([school_admin, cluster_admin, staff, staff_2, staff_2])
      expect(subject.all_adult_school_users.sort { |a, b| a.email <=> b.email }).to match_array([school_admin, cluster_admin, staff, staff_2].sort { |a, b| a.email <=> b.email })
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
    let(:school) { create :school, visible: true, data_enabled: true }

    it 'returns expected lists' do
      expect(School.awaiting_activation).to be_empty
      school.update!(visible: false)
      expect(School.awaiting_activation).to match_array([school])
      school.update!(visible: true, data_enabled: false)
      expect(School.awaiting_activation).to match_array([school])
    end
  end

  context 'with school times' do
    let(:school) { create :school, visible: true, data_enabled: true }

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
    let(:calendar) { create :school_calendar }
    let(:academic_year) { calendar.academic_years.last }
    let(:school) { create :school, calendar: calendar }
    let(:date_1) { academic_year.start_date + 1.month}
    let(:date_2) { academic_year.start_date - 1.month}
    let!(:activity_1) { create :activity, happened_on: date_1, school: school }
    let!(:activity_2) { create :activity, happened_on: date_2, school: school }

    it 'finds activities from the academic year' do
      expect(school.activities_in_academic_year(academic_year.start_date + 2.months)).to eq([activity_1])
    end
  end

  describe 'with actions' do
    let(:calendar) { create :school_calendar }
    let(:academic_year) { calendar.academic_years.last }
    let(:school) { create :school, calendar: calendar }
    let(:date_1) { academic_year.start_date + 1.month}
    let(:date_2) { academic_year.start_date - 1.month}
    let!(:intervention_type_1) { create :intervention_type }
    let!(:intervention_type_2) { create :intervention_type }
    let!(:observation_1) { create :observation, :intervention, at: date_1, school: school, intervention_type: intervention_type_1 }
    let!(:observation_2) { create :observation, :intervention, at: date_2, school: school, intervention_type: intervention_type_2 }
    let!(:observation_without_intervention_type) { create(:observation, :temperature, at: date_1 + 1.day, school: school) }

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

    describe '#subscription_frequency' do
      it 'returns the subscription frequency for a school if there is a holiday approaching' do
        allow(school).to receive(:holiday_approaching?) { true }
        expect(school.subscription_frequency).to eq([:weekly, :termly, :before_each_holiday])
      end

      it 'returns the subscription frequency for a school if there is not a holiday approaching' do
        allow(school).to receive(:holiday_approaching?) { false }
        expect(school.subscription_frequency).to eq([:weekly])
      end
    end

    context 'when finding intervention types by date' do
      let!(:recent_observation) { create(:observation, :intervention, at: date_1 + 1.day, school: school, intervention_type: intervention_type_2) }
      it 'finds intervention types by date, including duplicates, excluding non-intervention observations' do
        expect(school.intervention_types_by_date).to eq([intervention_type_2, intervention_type_1, intervention_type_2])
      end
    end
  end

  describe '.all_pseudo_meter_attributes' do
    let(:school_group)    { create(:school_group) }
    let(:school)          { create(:school, school_group: school_group) }
    let(:feature_flag)    { 'false' }

    around do |example|
      ClimateControl.modify FEATURE_FLAG_NEW_ENERGY_TARIFF_EDITOR: feature_flag do
        example.run
      end
    end

    context 'with :new_energy_tariff_editor enabled' do
      let(:feature_flag) { 'true' }

      let(:all_pseudo_meter_attributes) { school.all_pseudo_meter_attributes }

      let!(:global_meter_attribute)       do
        GlobalMeterAttribute.create(attribute_type: 'accounting_tariff',
        meter_types: ["aggregated_electricity"], input_data: {})
      end
      let!(:school_group_meter_attribute) do
        SchoolGroupMeterAttribute.create(attribute_type: 'economic_tariff',
        meter_types: ["", "electricity", "aggregated_electricity"], school_group: school_group, input_data: {})
      end

      context 'when there are tariffs stored as pseudo meter attributes' do
        it 'ignores them' do
          expect(all_pseudo_meter_attributes[:aggregated_electricity]).to be_empty
        end
      end

      context 'when there are tariffs stored as EnergyTariffs' do
        let!(:site_wide)        { create(:energy_tariff, :with_flat_price, tariff_holder: SiteSettings.current) }
        let!(:group_level)      { create(:energy_tariff, :with_flat_price, tariff_holder: school_group) }
        let!(:school_specific)  { create(:energy_tariff, :with_flat_price, tariff_holder: school) }
        let!(:target) { create(:school_target, start_date: Date.yesterday, school: school) }
        let!(:estimate)  { create(:estimated_annual_consumption, school: school, electricity: 1000.0, gas: 1500.0, storage_heaters: 500.0, year: 2021) }

        it 'maps them to the pseudo meters, targets, and estimates' do
          expect(all_pseudo_meter_attributes[:aggregated_electricity].size).to eq 5
          expect(all_pseudo_meter_attributes[:aggregated_electricity].map(&:attribute_type)).to match_array(
            %w[
              targeting_and_tracking
              estimated_period_consumption
              accounting_tariff_generic
              accounting_tariff_generic
              accounting_tariff_generic
            ]
          )
        end
      end
    end
  end
end

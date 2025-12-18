# frozen_string_literal: true

require 'rails_helper'

describe School do
  subject(:school) { create(:school, :with_school_group, calendar: calendar) }

  let(:today) { Time.zone.today }
  let(:calendar) { create(:calendar) }

  it 'is valid with valid attributes' do
    expect(school).to be_valid
  end

  it 'builds a slug on create using :name' do
    expect(school.slug).to eq(school.name.parameterize)
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
      expect(described_class.all).to contain_exactly(school_1, school_2)
      expect(described_class.with_energy_tariffs).to eq([school_1])
    end
  end

  describe '#minimum_reading_date' do
    it 'returns the minimum amr validated readings date minus 1 year if amr_validated_readings are present' do
      meter = create(:electricity_meter, school: school)
      meter2 = create(:electricity_meter, school: school)
      meter3 = create(:electricity_meter, school: school)

      base_date = Time.zone.today - 1.year
      create(:amr_validated_reading, meter: meter, reading_date: base_date)
      create(:amr_validated_reading, meter: meter, reading_date: base_date + 2.days)
      create(:amr_validated_reading, meter: meter, reading_date: base_date + 4.days)
      create(:amr_validated_reading, meter: meter2, reading_date: base_date + 1.day)
      create(:amr_validated_reading, meter: meter2, reading_date: base_date + 2.days)
      create(:amr_validated_reading, meter: meter3, reading_date: base_date + 6.days)

      expect(school.minimum_reading_date).to eq(base_date - 1.year)
      expect(school.minimum_reading_date).to eq(AmrValidatedReading.where(meter_id: meter.id).minimum(:reading_date) - 1.year)
    end

    it 'returns nil if amr_validated_readings are not present' do
      expect(school.minimum_reading_date).to be_nil
    end
  end

  context 'when validating alternative heating percent fields' do
    let(:heating_fields) do
      %i[
        heating_oil_percent
        heating_lpg_percent
        heating_biomass_percent
        heating_district_heating_percent
        heating_ground_source_heat_pump_percent
        heating_air_source_heat_pump_percent
        heating_gas_percent
        heating_electric_percent
        heating_underfloor_percent
        heating_chp_percent
      ]
    end

    it 'validates alternative heating percentages' do
      heating_fields.each do |field|
        expect(school).to validate_numericality_of(field).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100).allow_nil
      end
    end
  end

  it 'validates postcodes' do
    ['BA2 £3Z', 'BA14 9 DU', 'TS11 7B'].each do |invalid|
      school.postcode = invalid
      expect(school).not_to be_valid
    end
    ['OL84JZ', 'OL8 4JZ'].each do |valid|
      school.postcode = valid
      expect(school).to be_valid
    end
  end

  it 'validates free school meals' do
    [-1, 200].each do |invalid|
      school.percentage_free_school_meals = invalid
      expect(school).not_to be_valid
    end
    school.percentage_free_school_meals = 20
    expect(school).to be_valid
  end

  describe 'FriendlyID#slug_candidates' do
    context 'when two schools have the same name' do
      it 'builds a different slug using :postcode and :name' do
        school = create_list(:school_with_same_name, 2).last
        expect(school.slug).to eq([school.postcode, school.name].join('-').parameterize)
      end
    end

    context 'when three schools have the same name and postcode' do
      it 'builds a different slug using :urn and :name' do
        school = create_list(:school_with_same_name, 3).last
        expect(school.slug).to eq([school.urn, school.name].join('-').parameterize)
      end
    end
  end

  describe '#fuel_types' do
    it 'identifies dual fuel if it has both meters' do
      fuel_configuration = Schools::FuelConfiguration.new(has_gas: true, has_electricity: true)
      school.configuration.update(fuel_configuration: fuel_configuration)
      expect(school.fuel_types).to eq :electric_and_gas
    end

    it 'identifies electricity if it has electricity only' do
      fuel_configuration = Schools::FuelConfiguration.new(has_gas: false, has_electricity: true)
      school.configuration.update(fuel_configuration: fuel_configuration)
      expect(school.fuel_types).to eq :electric_only
    end

    it 'identifies gas if it has gas only' do
      fuel_configuration = Schools::FuelConfiguration.new(has_gas: true, has_electricity: false)
      school.configuration.update(fuel_configuration: fuel_configuration)
      expect(school.fuel_types).to eq :gas_only
    end
  end

  describe '#meters_with_readings' do
    it 'works if explicitly giving a supply type of electricity' do
      electricity_meter = create(:electricity_meter_with_reading, reading_count: 10, school: school)
      expect(school.meters_with_readings(:electricity).first).to eq electricity_meter
      expect(school.meters_with_readings(:gas)).to be_empty
    end

    it 'works if explicitly giving a supply type of gas' do
      gas_meter = create(:gas_meter_with_reading, reading_count: 10, school: school)
      expect(school.meters_with_readings(:gas).first).to eq gas_meter
      expect(school.meters_with_readings(:electricity)).to be_empty
    end

    it 'works without a supply type for a gas meter' do
      gas_meter = create(:gas_meter_with_reading, reading_count: 10, school: school)
      expect(school.meters_with_readings.first).to eq gas_meter
    end

    it 'works without a supply type for an electricity' do
      electricity_meter = create(:electricity_meter_with_reading, reading_count: 10, school: school)
      expect(school.meters_with_readings.first).to eq electricity_meter
    end

    it 'ignores deactivated meters' do
      electricity_meter = create(:electricity_meter_with_reading, reading_count: 10, school: school)
      create(:electricity_meter_with_reading, reading_count: 10, school: school, active: false)
      expect(school.meters_with_readings(:electricity)).to contain_exactly(electricity_meter)
    end
  end

  describe '#meters_with_validated_readings' do
    it 'works if explicitly giving a supply type of electricity' do
      electricity_meter = create(:electricity_meter_with_validated_reading, reading_count: 10, school: school)
      expect(school.meters_with_validated_readings(:electricity).first).to eq electricity_meter
      expect(school.meters_with_validated_readings(:gas)).to be_empty
    end

    it 'works if explicitly giving a supply type of gas' do
      gas_meter = create(:gas_meter_with_validated_reading, reading_count: 10, school: school)
      expect(school.meters_with_validated_readings(:gas).first).to eq gas_meter
      expect(school.meters_with_validated_readings(:electricity)).to be_empty
    end

    it 'works without a supply type for a gas meter' do
      gas_meter = create(:gas_meter_with_validated_reading, reading_count: 10, school: school)
      expect(school.meters_with_validated_readings.first).to eq gas_meter
    end

    it 'works without a supply type for an electricity' do
      electricity_meter = create(:electricity_meter_with_validated_reading, reading_count: 10, school: school)
      expect(school.meters_with_validated_readings.first).to eq electricity_meter
    end

    it 'ignores deactivated meters' do
      electricity_meter = create(:electricity_meter_with_validated_reading, reading_count: 10, school: school)
      create(:electricity_meter_with_validated_reading, school: school, active: false)
      expect(school.meters_with_validated_readings(:electricity)).to contain_exactly(electricity_meter)
    end
  end

  describe '#latest_alerts_without_exclusions' do
    let(:school) { create(:school) }
    let(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity, frequency: :termly) }

    context 'where there is an alert run' do
      let(:alert_generation_run_1) { create(:alert_generation_run, school: school, created_at: 1.day.ago) }
      let(:alert_generation_run_2) { create(:alert_generation_run, school: school, created_at: Time.zone.today) }

      let!(:alert_1) do
        create(:alert, alert_type: electricity_fuel_alert_type, school: school,
                       alert_generation_run: alert_generation_run_1)
      end
      let!(:alert_2) do
        create(:alert, alert_type: electricity_fuel_alert_type, school: school,
                       alert_generation_run: alert_generation_run_2)
      end

      it 'selects the dashboard alerts from the most recent run' do
        expect(school.latest_alerts_without_exclusions).to contain_exactly(alert_2)
      end
    end

    context 'where there is no run' do
      it 'returns an empty set' do
        expect(school.latest_alerts_without_exclusions).to be_empty
      end
    end
  end

  describe '#latest_dashboard_alerts' do
    let(:school) { create(:school) }
    let(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity, frequency: :termly) }
    let(:alert_type_rating) { create(:alert_type_rating, alert_type: electricity_fuel_alert_type) }

    let(:content_version_1) { create(:alert_type_rating_content_version, alert_type_rating: alert_type_rating) }
    let(:alert_1) { create(:alert, alert_type: electricity_fuel_alert_type) }
    let(:alert_2) { create(:alert, alert_type: electricity_fuel_alert_type) }
    let(:content_generation_run_1) { create(:content_generation_run, school: school, created_at: 1.day.ago) }
    let(:content_generation_run_2) { create(:content_generation_run, school: school, created_at: Time.zone.today) }

    context 'where there is a content run' do
      let!(:dashboard_alert_1) do
        create(:dashboard_alert, alert: alert_1, content_version: content_version_1,
                                 content_generation_run: content_generation_run_1)
      end
      let!(:dashboard_alert_2) do
        create(:dashboard_alert, alert: alert_1, content_version: content_version_1,
                                 content_generation_run: content_generation_run_2)
      end

      it 'selects the dashboard alerts from the most recent run' do
        expect(school.latest_dashboard_alerts).to contain_exactly(dashboard_alert_2)
      end
    end

    context 'where there is no run' do
      it 'returns an empty set' do
        expect(school.latest_dashboard_alerts).to be_empty
      end
    end
  end

  describe 'authenticate_pupil' do
    let(:school) { create(:school) }
    let(:valid_password) { 'three memorable Words 123' }
    let!(:pupil) { create(:pupil, pupil_password: valid_password, school: school) }

    it 'selects pupils with the correct password' do
      expect(school.authenticate_pupil(valid_password)).to eq(pupil)
    end

    it 'returns nothing if the password does not match' do
      expect(school.authenticate_pupil('barp')).to be_nil
      expect(school.authenticate_pupil('three memorable words')).to be_nil
    end

    it 'is not case sensitive' do
      expect(school.authenticate_pupil('three memorable words 123')).to eq(pupil)
    end
  end

  describe 'process_data!' do
    it 'errors when the school has no meters with readings' do
      school = create(:school, process_data: false)
      expect do
        school.process_data!
      end.to raise_error(School::ProcessDataError, /has no meter readings/)
      expect(school.process_data).to be(false)
    end

    it 'errors when the school has no floor area' do
      school = create(:school, process_data: false, floor_area: nil)
      create(:electricity_meter_with_reading, school: school)
      expect do
        school.process_data!
      end.to raise_error(School::ProcessDataError, /has no floor area/)
      expect(school.process_data).to be(false)
    end

    it 'errors when the school has no pupil numbers' do
      school = create(:school, process_data: false, number_of_pupils: nil)
      create(:electricity_meter_with_reading, school: school)
      expect do
        school.process_data!
      end.to raise_error(School::ProcessDataError, /has no pupil numbers/)
      expect(school.process_data).to be(false)
    end

    it 'does not error when the school has floor area, pupil numbers and a meter' do
      school = create(:school, process_data: false)
      create(:electricity_meter_with_reading, school: school)
      expect do
        school.process_data!
      end.not_to raise_error
      expect(school.process_data).to be(true)
    end
  end

  describe 'geolocation' do
    it 'the school is geolocated on creation' do
      school = create(:school, latitude: nil, longitude: nil)
      expect(school.latitude).not_to be_nil
      expect(school.longitude).not_to be_nil
    end

    it 'the school is geolocated if the postcode is changed' do
      school = create(:school)
      school.update(latitude: 55.952221, longitude: -3.174625, country: 'scotland')
      school.reload

      expect(school.latitude).to eq(55.952221)
      expect(school.longitude).to eq(-3.174625)
      expect(school.country).to eq('scotland')

      school.update(postcode: 'OL8 4JZ')
      school.reload

      # values from default stub on Geocoder::Lookup::Test
      expect(school.latitude).to eq(51.340620)
      expect(school.longitude).to eq(-2.301420)
      expect(school.country).to eq('england')
    end

    it 'passes validation with a findable postcode' do
      school = build(:school, postcode: 'EH99 1SP')
      expect(school.valid?).to be(true)
      expect(school.errors.messages).to eq({})
      expect(school.latitude).to eq(55.952221)
      expect(school.longitude).to eq(-3.174625)
      expect(school.country).to eq('scotland')
    end

    it 'fails validation with a non findable postcode' do
      school = build(:school, postcode: 'EH99 2SP')
      expect(school.valid?).to be(false)
      expect(school.errors.messages[:postcode]).to eq(['not found.'])
      expect(school.latitude).to be_nil
      expect(school.longitude).to be_nil
      expect(school.country).to be_nil
    end
  end

  context 'with partners' do
    let(:partner)       { create(:partner) }
    let(:other_partner) { create(:partner) }

    it 'can add a partner' do
      expect(SchoolPartner.count).to be(0)
      school.partners << partner
      expect(SchoolPartner.count).to be(1)
    end

    it 'orders partners by position' do
      SchoolPartner.create(school: school, partner: partner, position: 1)
      SchoolPartner.create(school: school, partner: other_partner, position: 0)
      expect(school.partners.first).to eql(other_partner)
      expect(school.partners).to contain_exactly(other_partner, partner)
    end

    it 'finds all partners' do
      expect(school.displayable_partners).to match([])
      school.partners << partner
      expect(school.displayable_partners).to match([partner])
      school.school_group.partners << other_partner
      expect(school.displayable_partners).to match([partner, other_partner])
      school.partners.destroy_all
      expect(school.displayable_partners).to match([other_partner])
    end
  end

  context 'with consent' do
    let!(:consent_statement) { create(:consent_statement, current: true) }

    it 'identifies whether consent is current' do
      expect(school.consent_up_to_date?).to be false
      create(:consent_grant, school: school)
      expect(school.consent_up_to_date?).to be false
      create(:consent_grant, school: school, consent_statement: consent_statement)
      expect(school.consent_up_to_date?).to be true
    end
  end

  context 'with live data' do
    let(:cad) { create(:cad, school: school, active: true) }

    it 'checks for presence of active cads' do
      expect(school.has_live_data?).to be false
      school.cads << cad
      expect(school.has_live_data?).to be true
      cad.update(active: false)
      expect(school.has_live_data?).to be false
    end
  end

  context 'with annual estimates' do
    it 'there are no meter attributes without an estimate' do
      expect(school.estimated_annual_consumption_meter_attributes).to eql({})
      expect(school.all_pseudo_meter_attributes).to eql({ aggregated_electricity: [], aggregated_gas: [],
                                                          solar_pv_consumed_sub_meter: [], solar_pv_exported_sub_meter: [] })
    end

    context 'when an estimate is given' do
      let!(:estimate) do
        create(:estimated_annual_consumption, school: school, electricity: 1000.0, gas: 1500.0, storage_heaters: 500.0,
                                              year: 2021)
      end

      before do
        school.reload
      end

      it 'they are not passed to the analytics' do
        expect(school.all_pseudo_meter_attributes).to eql({ aggregated_electricity: [], aggregated_gas: [],
                                                            solar_pv_consumed_sub_meter: [], solar_pv_exported_sub_meter: [] })
      end
    end
  end

  context 'with school targets' do
    it 'there is no target by default' do
      expect(school.has_target?).to be false
      expect(school.current_target).to be_nil
    end

    it 'there are no meter attributes without a target' do
      expect(school.school_target_attributes).to eql({})
      expect(school.all_pseudo_meter_attributes).to eql({ aggregated_electricity: [], aggregated_gas: [],
                                                          solar_pv_consumed_sub_meter: [], solar_pv_exported_sub_meter: [] })
    end

    context 'when a target is set' do
      let!(:target) { create(:school_target, start_date: Date.yesterday, school: school) }

      before do
        school.reload
      end

      it 'finds the target' do
        expect(school.has_target?).to be true
        expect(school.has_current_target?).to be true
        expect(school.current_target).to eql target
        expect(school.most_recent_target).to eql target
        expect(school.expired_target).to be_nil
        expect(school.has_expired_target?).to be false
      end

      it 'the target should add meter attributes' do
        expect(school.all_pseudo_meter_attributes[:aggregated_electricity]).not_to be_empty
      end

      context 'with multiple targets' do
        let!(:future_target) { create(:school_target, start_date: Date.tomorrow, school: school) }

        it 'finds the current target' do
          expect(school.has_target?).to be true
          expect(school.has_current_target?).to be true
          expect(school.current_target).to eql target
          expect(school.most_recent_target).to eql future_target
          expect(school.expired_target).to be_nil
          expect(school.has_expired_target?).to be false
        end
      end

      context 'with expired target' do
        before do
          target.update!(start_date: Date.yesterday.prev_year)
        end

        it 'finds the expired target' do
          expect(school.has_target?).to be true
          expect(school.has_current_target?).to be false
          expect(school.current_target).to be_nil
          expect(school.most_recent_target).to eql target
          expect(school.expired_target).to eq target
          expect(school.has_expired_target?).to be true
        end

        it 'stills produce meter attributes' do
          expect(school.all_pseudo_meter_attributes[:aggregated_electricity]).not_to be_empty
        end
      end

      describe '#previous_expired_target' do
        let!(:expired_target) { create(:school_target, start_date: Date.yesterday.prev_year, school: school) }
        let!(:older_expired_target) { create(:school_target, start_date: Date.yesterday.years_ago(2), school: school) }
        let!(:oldest_expired_target) do
          create(:school_target, start_date: Date.yesterday.years_ago(3), school: school)
        end

        it { expect(school.previous_expired_target(expired_target)).to eq older_expired_target }
        it { expect(school.previous_expired_target(older_expired_target)).to eq oldest_expired_target }
        it { expect(school.previous_expired_target(oldest_expired_target)).to be_nil }
        it { expect(school.previous_expired_target(nil)).to be_nil }
        it { expect(school.previous_expired_target(target)).to be_nil }
      end
    end
  end

  context 'school users' do
    let!(:school_admin)     { create(:school_admin, school: school, email: 'school_user_1@test.com') }
    let!(:cluster_admin)    do
      create(:school_admin, name: 'Cluster admin', cluster_schools: [school], email: 'school_user_2@test.com')
    end
    let!(:staff)            { create(:staff, school: school, email: 'school_user_3@test.com') }
    let!(:staff_2)          do
      create(:staff, school: school, cluster_schools: [school], email: 'school_user_4@test.com')
    end
    let!(:pupil) { create(:pupil, school: school, email: 'school_user_5@test.com') }

    it 'identifies different groups' do
      expect(school.school_admin).to contain_exactly(school_admin)
      expect(school.cluster_users).to contain_exactly(cluster_admin, staff_2)
      expect(school.staff).to contain_exactly(staff, staff_2)
      expect(school.all_school_admins.sort_by(&:email)).to match_array([staff_2, school_admin,
                                                                        cluster_admin].sort_by(&:email))
      expect((school.all_school_admins + school.staff).sort_by(&:email)).to contain_exactly(school_admin,
                                                                                            cluster_admin, staff, staff_2, staff_2)
      expect(school.all_adult_school_users.sort_by(&:email)).to match_array([school_admin, cluster_admin, staff,
                                                                             staff_2].sort_by(&:email))
    end

    it 'handles empty lists' do
      school = create(:school)
      expect(school.school_admin).to be_empty
      expect(school.cluster_users).to be_empty
      expect(school.staff).to be_empty
      expect(school.all_school_admins).to be_empty
      expect(school.all_adult_school_users).to be_empty

      new_admin = create(:school_admin, school: school)
      expect(school.all_school_admins).to contain_exactly(new_admin)
      expect(school.all_adult_school_users).to contain_exactly(new_admin)
    end
  end

  describe '#awaiting_activation' do
    let(:school) { create(:school, visible: true, data_enabled: true) }

    it 'returns expected lists' do
      expect(described_class.awaiting_activation).to be_empty
      school.update!(visible: false)
      expect(described_class.awaiting_activation).to contain_exactly(school)
      school.update!(visible: true, data_enabled: false)
      expect(described_class.awaiting_activation).to contain_exactly(school)
    end
  end

  context 'with school times' do
    let(:school) { create(:school, visible: true, data_enabled: true) }

    let!(:school_day) do
      create(:school_time, school: school, day: :tuesday, usage_type: :school_day, opening_time: 815,
                           closing_time: 1520)
    end

    let!(:community_use) do
      create(:school_time, school: school, day: :monday, usage_type: :community_use, opening_time: 1800,
                           closing_time: 2030)
    end

    it 'serialises school day' do
      times = school.school_times_to_analytics
      expect(times.length).to eq 1
      expect(times[0][:day]).to be :tuesday
    end

    it 'serialises community_use' do
      times = school.community_use_times_to_analytics
      expect(times.length).to eq 1
      expect(times[0][:day]).to be :monday
    end
  end

  describe 'with activities' do
    let(:calendar) { create(:school_calendar) }
    let(:academic_year) { calendar.academic_years.last }
    let(:school) { create(:school, calendar: calendar) }
    let(:date_1) { academic_year.start_date + 1.month }
    let(:date_2) { academic_year.start_date - 1.month }
    let!(:activity_1) { create(:activity, happened_on: date_1, school: school) }
    let!(:activity_2) { create(:activity, happened_on: date_2, school: school) }

    it 'finds activity_types from the academic year' do
      expect(school.activity_types_in_academic_year(academic_year.start_date + 2.months)).to eq([activity_1.activity_type])
    end

    it 'handles missing academic year' do
      expect(school.activity_types_in_academic_year(Date.parse('01-01-1900'))).to eq([])
    end
  end

  describe 'with actions' do
    let(:calendar) { create(:school_calendar) }
    let(:academic_year) { calendar.academic_years.last }
    let(:school) { create(:school, calendar: calendar) }
    let(:date_1) { academic_year.start_date + 1.month }
    let(:date_2) { academic_year.start_date - 1.month }
    let!(:intervention_type_1) { create(:intervention_type) }
    let!(:intervention_type_2) { create(:intervention_type) }
    let!(:observation_1) do
      create(:observation, :intervention, at: date_1, school: school, intervention_type: intervention_type_1)
    end
    let!(:observation_2) do
      create(:observation, :intervention, at: date_2, school: school, intervention_type: intervention_type_2)
    end
    let!(:observation_without_intervention_type) do
      create(:observation, :temperature, at: date_1 + 1.day, school: school)
    end

    it 'finds intervention types from the academic year' do
      expect(school.intervention_types_in_academic_year(academic_year.start_date + 2.months)).to eq([intervention_type_1])
    end

    it 'handles missing academic year' do
      expect(school.intervention_types_in_academic_year(Date.parse('01-01-1900'))).to eq([])
    end

    describe '#subscription_frequency' do
      it 'returns the subscription frequency for a school if there is a holiday approaching' do
        allow(school).to receive(:holiday_approaching?).and_return(true)
        expect(school.subscription_frequency).to eq(%i[weekly termly before_each_holiday])
      end

      it 'returns the subscription frequency for a school if there is not a holiday approaching' do
        allow(school).to receive(:holiday_approaching?).and_return(false)
        expect(school.subscription_frequency).to eq([:weekly])
      end
    end
  end

  describe '.all_pseudo_meter_attributes' do
    let(:school_group)    { create(:school_group) }
    let(:school)          { create(:school, school_group: school_group) }

    let(:all_pseudo_meter_attributes) { school.all_pseudo_meter_attributes }

    context 'when there are EnergyTariffs' do
      let!(:site_wide)        { create(:energy_tariff, :with_flat_price, tariff_holder: SiteSettings.current) }
      let!(:group_level)      { create(:energy_tariff, :with_flat_price, tariff_holder: school_group) }
      let!(:school_specific)  { create(:energy_tariff, :with_flat_price, tariff_holder: school) }
      let!(:target) { create(:school_target, start_date: Date.yesterday, school: school) }
      let!(:estimate) do
        create(:estimated_annual_consumption, school: school, electricity: 1000.0, gas: 1500.0, storage_heaters: 500.0,
                                              year: 2021)
      end

      it 'maps them to the pseudo meters, targets, and estimates' do
        expect(all_pseudo_meter_attributes[:aggregated_electricity].size).to eq 4
        expect(all_pseudo_meter_attributes[:aggregated_electricity].map(&:attribute_type)).to match_array(
          %w[
            targeting_and_tracking
            accounting_tariff_generic
            accounting_tariff_generic
            accounting_tariff_generic
          ]
        )
      end
    end
  end

  describe 'weather_station required' do
    it { is_expected.to validate_presence_of(:weather_station) }
  end

  # To be removed when todos feature removed
  describe '#suggested_programme_types', without_feature: :todos do
    subject(:programme_types) { school.suggested_programme_types }

    let(:school) { create(:school) }

    let!(:programme_type_1) { create(:programme_type_with_activity_types, title: 'programme 1') }
    let!(:programme_type_2) { create(:programme_type_with_activity_types, title: 'programme 2') }

    def create_activity(activity_type, happened_on: Time.zone.now)
      school.activities.create!(activity_type: activity_type, activity_category: activity_type.activity_category,
                                happened_on: happened_on)
    end

    context 'when school has not completed any activities at all' do
      it { expect(programme_types).to be_empty }
    end

    context 'when school has completed activities from a programme type' do
      before do
        create_activity(programme_type_1.activity_types.first)
        create_activity(programme_type_1.activity_types.second)
      end

      it { expect(programme_types).to include(programme_type_1) }
      it { expect(programme_types.length).to be(1) }

      it 'includes a count of activity_types completed in programme' do
        expect(programme_types.first.activity_type_count).to be(2)
      end

      context 'when school is already subscribed to programme type' do
        before do
          school.programmes.create!(programme_type: programme_type_1, started_on: Time.zone.now)
        end

        it 'is not suggested' do
          expect(programme_types).to be_empty
        end
      end
    end

    context 'when school has completed activities from multiple programme types' do
      before do
        create_activity(programme_type_2.activity_types.first)
        create_activity(programme_type_2.activity_types.second)

        create_activity(programme_type_1.activity_types.first)
      end

      it 'orders by activity_count desc' do
        expect(programme_types.first).to eq(programme_type_2)
        expect(programme_types.second).to eq(programme_type_1)
      end

      it 'includes activity counts' do
        expect(programme_types.first.activity_type_count).to be(2)
        expect(programme_types.second.activity_type_count).to be(1)
      end
    end

    context 'when school has completed the same activity several times' do
      before do
        create_activity(programme_type_1.activity_types.first)
        create_activity(programme_type_1.activity_types.first)
        create_activity(programme_type_1.activity_types.first)
      end

      it 'includes a counts the activity types once' do
        expect(programme_types.first.activity_type_count).to be(1)
      end
    end

    context 'when activity was completed in a previous academic year' do
      before do
        create_activity(programme_type_1.activity_types.first, happened_on: 2.years.ago)
      end

      it "doesn't include programme" do
        expect(programme_types.length).to be(0)
      end

      context 'when another activity was in current year' do
        before do
          create_activity(programme_type_1.activity_types.second, happened_on: Time.zone.now)
        end

        it 'includes programme' do
          expect(programme_types.first).to eq(programme_type_1)
        end
      end
    end

    context 'when school has completed activities not in existing programmes' do
      before { create_activity(create(:activity_type)) }

      it { expect(programme_types).to be_empty }
    end
  end

  def create_observation(intervention_type, at: Time.zone.now)
    school.observations.intervention.create!(intervention_type: intervention_type, at: at)
  end

  def create_activity(activity_type, happened_on: Time.zone.now)
    school.activities.create!(activity_type: activity_type, activity_category: activity_type.activity_category,
                              happened_on: happened_on)
  end

  describe '#suggested_programme_types_from_activities' do
    subject(:programme_types) { school.suggested_programme_types_from_activities }

    let(:school) { create(:school) }

    let!(:programme_type_1) { create(:programme_type, :with_todos, title: 'programme 1') }
    let!(:programme_type_2) { create(:programme_type, :with_todos, title: 'programme 2') }

    context 'when school has not completed any activities at all' do
      it { expect(programme_types).to be_empty }
    end

    context 'when school has completed activities from a programme type' do
      before do
        create_activity(programme_type_1.activity_type_tasks.first)
        create_activity(programme_type_1.activity_type_tasks.second)
      end

      it { expect(programme_types).to include(programme_type_1) }
      it { expect(programme_types.length).to be(1) }

      it 'includes a count of activity_types completed in programme' do
        expect(programme_types.first.recording_count).to be(2)
      end

      context 'when school is already subscribed to programme type' do
        before do
          school.programmes.create!(programme_type: programme_type_1, started_on: Time.zone.now)
        end

        it 'is not suggested' do
          expect(programme_types).to be_empty
        end
      end
    end

    context 'when school has completed activities from multiple programme types' do
      before do
        create_activity(programme_type_2.activity_type_tasks.first)
        create_activity(programme_type_2.activity_type_tasks.second)

        create_activity(programme_type_1.activity_type_tasks.first)
      end

      it 'orders by recording_count desc' do
        expect(programme_types.first).to eq(programme_type_2)
        expect(programme_types.second).to eq(programme_type_1)
      end

      it 'includes recording counts' do
        expect(programme_types.first.recording_count).to be(2)
        expect(programme_types.second.recording_count).to be(1)
      end
    end

    context 'when school has completed the same activity several times' do
      before do
        3.times { create_activity(programme_type_1.activity_type_tasks.first) }
      end

      it 'counts the activity types once' do
        expect(programme_types.first.recording_count).to be(1)
      end
    end

    context 'when activity was completed in a previous academic year' do
      before do
        create_activity(programme_type_1.activity_type_tasks.first, happened_on: 2.years.ago)
      end

      it "doesn't include programme" do
        expect(programme_types.length).to be(0)
      end

      context 'when another activity was in current year' do
        before do
          create_activity(programme_type_1.activity_type_tasks.second, happened_on: Time.zone.now)
        end

        it 'includes programme' do
          expect(programme_types.first).to eq(programme_type_1)
        end
      end
    end

    context 'when school has completed activities not in existing programmes' do
      before { create_activity(create(:activity_type)) }

      it { expect(programme_types).to be_empty }
    end
  end

  describe '#suggested_programme_types_from_actions' do
    subject(:programme_types) { school.suggested_programme_types_from_actions }

    let(:school) { create(:school) }

    let!(:programme_type_1) { create(:programme_type, :with_todos, title: 'programme 1') }
    let!(:programme_type_2) { create(:programme_type, :with_todos, title: 'programme 2') }

    context 'when school has not completed any actions at all' do
      it { expect(programme_types).to be_empty }
    end

    context 'when school has completed actions from a programme type' do
      before do
        create_observation(programme_type_1.intervention_type_tasks.first)
        create_observation(programme_type_1.intervention_type_tasks.second)
      end

      it { expect(programme_types).to include(programme_type_1) }
      it { expect(programme_types.length).to be(1) }

      it 'includes a count of intervention_types completed in programme' do
        expect(programme_types.first.recording_count).to be(2)
      end

      context 'when school is already subscribed to programme type' do
        before do
          school.programmes.create!(programme_type: programme_type_1, started_on: Time.zone.now)
        end

        it 'is not suggested' do
          expect(programme_types).to be_empty
        end
      end
    end

    context 'when school has completed actions from multiple programme types' do
      before do
        create_observation(programme_type_2.intervention_type_tasks.first)
        create_observation(programme_type_2.intervention_type_tasks.second)

        create_observation(programme_type_1.intervention_type_tasks.first)
      end

      it 'orders by recording_count desc' do
        expect(programme_types.first).to eq(programme_type_2)
        expect(programme_types.second).to eq(programme_type_1)
      end

      it 'includes recording counts' do
        expect(programme_types.first.recording_count).to be(2)
        expect(programme_types.second.recording_count).to be(1)
      end
    end

    context 'when school has completed the same action several times' do
      before do
        3.times { create_observation(programme_type_1.intervention_type_tasks.first) }
      end

      it 'counts the intervention types once' do
        expect(programme_types.first.recording_count).to be(1)
      end
    end

    context 'when action was completed in a previous academic year' do
      before do
        create_observation(programme_type_1.intervention_type_tasks.first, at: 2.years.ago)
      end

      it "doesn't include programme" do
        expect(programme_types.length).to be(0)
      end

      context 'when another action was in current year' do
        before do
          create_observation(programme_type_1.intervention_type_tasks.second, at: Time.zone.now)
        end

        it 'includes programme' do
          expect(programme_types.first).to eq(programme_type_1)
        end
      end
    end

    context 'when school has completed actions not in existing programmes' do
      before { create_observation(create(:intervention_type)) }

      it { expect(programme_types).to be_empty }
    end
  end

  describe '#suggested_programme_type' do
    subject(:results) { school.suggested_programme_type }

    let(:school) { create(:school) }
    let(:programme_type) { results.first }
    let(:count) { results.second }

    context 'when there are two programmes' do
      let!(:programme_type_1) { create(:programme_type, :with_todos, title: 'programme 1') }
      let!(:programme_type_2) { create(:programme_type, :with_todos, title: 'programme 2') }

      context 'when school has not completed any tasks at all' do
        it { expect(results).to be_nil }
      end

      context 'when school has completed both activities and actions from the same programme_type' do
        before do
          create_observation(programme_type_1.intervention_type_tasks.first)
          create_observation(programme_type_1.intervention_type_tasks.second)
          create_activity(programme_type_1.activity_type_tasks.first)

          create_activity(programme_type_2.activity_type_tasks.first)
          create_activity(programme_type_2.activity_type_tasks.first)
        end

        it 'returns programme_type' do
          expect(programme_type).to eq(programme_type_1)
        end

        it 'counts both' do
          expect(count).to eq(3)
        end
      end

      context 'when two programmes have the same count' do
        before do
          create_observation(programme_type_1.intervention_type_tasks.first)
          create_activity(programme_type_1.activity_type_tasks.first)

          create_activity(programme_type_2.activity_type_tasks.first)
          create_activity(programme_type_2.activity_type_tasks.second)
        end

        it 'returns count' do
          expect(count).to eq(2)
        end

        it 'returns either of them' do
          expect(programme_type).to eq(programme_type_2)

          expect([programme_type_1, programme_type_2]).to include(programme_type)
        end
      end
    end

    context 'when there are several programme types and tasks have been completed for them all' do
      let!(:programme_types) { create_list(:programme_type, 4, :with_todos) }

      before do
        programme_types.each do |programme_type|
          # creates one of each intervention type for each programme
          3.times { |count| create_observation(programme_type.intervention_type_tasks[count]) }
          # creates the first two activity types for each programme
          2.times { |count| create_activity(programme_type.activity_type_tasks[count]) }
        end

        # creates the first two intervention types again for the first programme (not counted again)
        2.times { |count| create_observation(programme_types.first.intervention_type_tasks[count]) }
        # creates all three intervention types for the last programme (adds one more to count for last programme type)
        3.times { |count| create_activity(programme_types.last.activity_type_tasks[count]) }
      end

      it 'returns the programme with the greatest count' do
        expect(programme_type).to eq(programme_types.last)
        expect(count).to eq(6)
      end
    end
  end

  describe '#filterable_meters' do
    let!(:gas_meters) { create_list(:gas_meter, 2, school: school) }
    let!(:electricity_meters) { create_list(:electricity_meter, 2, school: school) }

    before do
      school.configuration.update!(fuel_configuration: Schools::FuelConfiguration.new(has_electricity: true,
                                                                                      has_gas: true))
    end

    it 'returns gas meters' do
      expect(school.filterable_meters(:gas)).to match_array(gas_meters)
    end

    it 'returns electricity meters' do
      expect(school.filterable_meters(:electricity)).to match_array(electricity_meters)
    end

    context 'with storage' do
      before do
        school.configuration.update!(fuel_configuration:
          Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true))
      end

      it 'returns gas meters' do
        expect(school.filterable_meters(:gas)).to match_array(gas_meters)
      end

      it 'returns no electricity meters' do
        expect(school.filterable_meters(:electricity)).to be_empty
      end
    end
  end

  describe '.school_list_for_login_form' do
    let!(:school) { create(:school, :with_school_group) }
    let!(:no_school_group) { create(:school) }

    it 'returns all schools' do
      schools = described_class.school_list_for_login_form
      expect(schools.length).to eq(2)
      expect(schools.first.name).to eq(school.name)
      expect(schools.first.school_group_name).to eq(school.school_group.name)
      expect(schools.last.name).to eq(no_school_group.name)
      expect(schools.last.school_group_name).to be_nil
    end
  end

  describe 'MailchimpUpdateable' do
    subject(:school) { create(:school) }

    it_behaves_like 'a MailchimpUpdateable' do
      let(:mailchimp_field_changes) do
        {
          active: false,
          country: :scotland,
          funder: create(:funder),
          local_authority_area: create(:local_authority_area),
          name: 'New name',
          percentage_free_school_meals: 15,
          region: :south_east,
          school_type: :special,
          school_group: create(:school_group),
          scoreboard: create(:scoreboard)
        }
      end

      let(:ignored_field_changes) do
        {
          address: 'Address',
          bill_requested: true
        }
      end
    end
  end

  describe '#engaged' do
    it 'counts active schools with observations' do
      create(:activity, school: school)
      create(:user, school: create(:school, active: false), last_sign_in_at: Time.current)
      expect(described_class.engaged(1.year.ago..)).to eq([school])
    end
  end

  describe '#floor_area_ok?' do
    shared_examples 'it checks boundaries' do
      it 'checks lower bound' do
        school = create(:school, school_type: school_type, number_of_pupils: 100, floor_area: low)
        expect(school.floor_area_ok?).not_to be(true)
      end

      it 'checks middle' do
        school = create(:school, school_type: school_type, number_of_pupils: 100, floor_area: ok)
        expect(school.floor_area_ok?).to be(true)
      end

      it 'checks upper bound' do
        school = create(:school, school_type: school_type, number_of_pupils: 100, floor_area: high)
        expect(school.floor_area_ok?).not_to be(true)
      end
    end

    context 'with middle' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :middle }
        let(:low) { 499 }
        let(:ok) { 1700 }
        let(:high) { 4801 }
      end
    end

    context 'with mixed_primary_and_secondary' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :mixed_primary_and_secondary }
        let(:low) { 499 }
        let(:ok) { 1700 }
        let(:high) { 4801 }
      end
    end

    context 'with secondary' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :secondary }
        let(:low) { 499 }
        let(:ok) { 1700 }
        let(:high) { 4801 }
      end
    end

    context 'with junior' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :junior }
        let(:low) { 99 }
        let(:ok) { 400 }
        let(:high) { 1801 }
      end
    end

    context 'with primary' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :primary }
        let(:low) { 99 }
        let(:ok) { 400 }
        let(:high) { 1801 }
      end
    end

    context 'with infant' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :infant }
        let(:low) { 99 }
        let(:ok) { 400 }
        let(:high) { 1801 }
      end
    end

    context 'with special' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :special }
        let(:low) { 99 }
        let(:ok) { 400 }
        let(:high) { 1801 }
      end
    end
  end

  describe '#pupil_numbers_ok?' do
    shared_examples 'it checks boundaries' do
      it 'checks lower bound' do
        school = create(:school, school_type: school_type, number_of_pupils: low)
        expect(school.pupil_numbers_ok?).not_to be(true)
      end

      it 'checks middle' do
        school = create(:school, school_type: school_type, number_of_pupils: ok)
        expect(school.pupil_numbers_ok?).to be(true)
      end

      it 'checks upper bound' do
        school = create(:school, school_type: school_type, number_of_pupils: high)
        expect(school.pupil_numbers_ok?).not_to be(true)
      end
    end

    context 'with middle' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :middle }
        let(:low) { 249 }
        let(:ok) { 500 }
        let(:high) { 1001 }
      end
    end

    context 'with mixed_primary_and_secondary' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :mixed_primary_and_secondary }
        let(:low) { 249 }
        let(:ok) { 500 }
        let(:high) { 1501 }
      end
    end

    context 'with secondary' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :secondary }
        let(:low) { 249 }
        let(:ok) { 500 }
        let(:high) { 1701 }
      end
    end

    context 'with junior' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :junior }
        let(:low) { 9 }
        let(:ok) { 500 }
        let(:high) { 1001 }
      end
    end

    context 'with primary' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :primary }
        let(:low) { 9 }
        let(:ok) { 500 }
        let(:high) { 801 }
      end
    end

    context 'with infant' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :infant }
        let(:low) { 9 }
        let(:ok) { 500 }
        let(:high) { 801 }
      end
    end

    context 'with special' do
      it_behaves_like 'it checks boundaries' do
        let(:school_type) { :special }
        let(:low) { 9 }
        let(:ok) { 250 }
        let(:high) { 501 }
      end
    end
  end

  describe '.from_onboarding' do
    context 'with matched outdated establishment' do
      let(:sch) do
        create(:closed_establishment, id: 1)
        create(:establishment, id: 2)
        create(:establishment_link, establishment_id: 1, linked_establishment_id: 2)
        onb = create(:school_onboarding, urn: 1, school_name: 'onboarding name')
        School.from_onboarding(onb)
      end

      it 'uses new establishment instead' do
        expect(sch.establishment_id).to eq(2)
      end

      it 'uses new establishment\'s urn instead' do
        expect(sch.urn).to eq(2)
      end
    end

    context 'with matched current establishment' do
      let(:sch) do
        create(:local_authority_area, code: 'a')
        create(:establishment, district_administrative_code: 'a', id: 1, establishment_name: 'establishment name', phase_of_education_code: 2, gor_code: 'A')
        onb = create(:school_onboarding, urn: 1, school_name: 'onboarding name')
        School.from_onboarding(onb)
      end

      it 'gets name from establishment instead of onboarding' do
        expect(sch.name).to eq('establishment name')
      end

      it 'finds local authority area from establishment' do
        expect(sch.local_authority_area).not_to be_nil
      end

      it 'gets school type from establishment' do
        expect(sch.school_type).to eq('primary')
      end

      it 'gets region from establishment' do
        expect(sch.region).to eq('north_east')
      end
    end

    context 'with no matched establishment' do
      let(:sch) do
        create(:local_authority_area, code: 'a')
        onb = create(:school_onboarding, school_name: 'onboarding name')
        School.from_onboarding(onb)
      end

      it 'defaults to name from onboarding' do
        expect(sch.name).to eq('onboarding name')
      end
    end
  end

  describe '.concatenate_address' do
    it 'skips empty elements' do
      expect(School.concatenate_address(['', 'a', '', 'b', ''])).to eq('a, b')
    end
  end

  describe 'when synchronising legacy group relationship' do
    let(:school_group) { create(:school_group, group_type: :multi_academy_trust) }
    let(:school) { build(:school, school_group: school_group) }

    describe 'after_create :sync_organisation_grouping_from_legacy' do
      context 'when school_group_id is present' do
        before { school.save }

        it 'creates an organisation school_grouping' do
          expect(SchoolGrouping.exists?(school_id: school.id, role: 'organisation')).to be true
        end

        it 'assigns the correct school_group_id to the grouping' do
          grouping = SchoolGrouping.find_by(school_id: school.id, role: 'organisation')
          expect(grouping.school_group).to eq(school_group)
        end
      end

      context 'when school_group_id is nil' do
        let(:school) { build(:school, school_group: nil) }

        before { school.save }

        it 'does not create an organisation school_grouping' do
          expect(SchoolGrouping.find_by(school_id: school.id, role: 'organisation')).to be_nil
        end
      end
    end

    describe 'after_update :sync_organisation_grouping_from_legacy' do
      let(:other_group) { create(:school_group, group_type: :multi_academy_trust) }

      before do
        school.save
        school.update(school_group: other_group)
      end

      it 'updates the organisation grouping with the new school_group_id' do
        grouping = SchoolGrouping.find_by(school_id: school.id, role: 'organisation')
        expect(grouping.school_group).to eq(other_group)
      end
    end

    describe 'creating organisation grouping on update if missing' do
      let(:school) { create(:school, school_group: nil) }

      before { school.update(school_group: school_group) }

      it 'creates a new organisation grouping' do
        expect(SchoolGrouping.exists?(school_id: school.id, role: 'organisation')).to be true
      end
    end

    describe 'destroys school groupings' do
      before do
        school.save
        school.destroy
      end

      it 'removes the organisation grouping' do
        expect(SchoolGrouping.find_by(school_id: school.id, role: 'organisation')).to be_nil
      end
    end
  end
end

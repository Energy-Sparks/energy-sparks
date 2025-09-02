# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a meter with a non half hourly meter system' do |meter_type, meter_systems|
  meter_systems.each do |meter_system|
    it 'includes all energy tariffs that are enabled irrespective of applies to value but with the parent filtered by the meters meter_system (non_half_hourly)' do
      meter.update(meter_system:, meter_type:)
      expect(meter.applies_to_for_meter_system).to eq(:non_half_hourly)
      expect(all_meter_attributes.size).to eq 9
      expect(all_meter_attributes[0].input_data['tariff_holder']).to eq 'site_settings'
      expect(all_meter_attributes[1].input_data['tariff_holder']).to eq 'site_settings'
      expect(all_meter_attributes[2].input_data['tariff_holder']).to eq 'school_group'
      expect(all_meter_attributes[3].input_data['tariff_holder']).to eq 'school_group'
      expect(all_meter_attributes[4].input_data['tariff_holder']).to eq 'school'
      expect(all_meter_attributes[5].input_data['tariff_holder']).to eq 'school'
      expect(all_meter_attributes[6].input_data['tariff_holder']).to eq 'meter'
      expect(all_meter_attributes[7].input_data['tariff_holder']).to eq 'meter'
      expect(all_meter_attributes[8].input_data['tariff_holder']).to eq 'meter'
      expect(all_meter_attributes.map { |m| m.input_data['name'] }).to contain_exactly(
        energy_tariff_site_wide_electricity_both.name,
        energy_tariff_site_wide_electricity_non_half_hourly.name,
        energy_tariff_group_level_electricity_both.name,
        energy_tariff_group_level_electricity_non_half_hourly.name,
        energy_tariff_school_electricity_both.name,
        energy_tariff_school_electricity_non_half_hourly.name,
        meter_specific_electricity_both.name, meter_specific_electricity_half_hourly.name,
        meter_specific_electricity_non_half_hourly.name
      )
    end
  end
end

RSpec.shared_examples 'a meter with a half hourly meter system' do |meter_type, meter_systems|
  meter_systems.each do |meter_system|
    it 'includes all energy tariffs that are enabled irrespective of applies to value but with the parent filtered by the meters meter_system (non_half_hourly)' do
      meter.update(meter_system:, meter_type:)
      expect(meter.applies_to_for_meter_system).to eq(:half_hourly)
      expect(all_meter_attributes.size).to eq 9
      expect(all_meter_attributes[0].input_data['tariff_holder']).to eq 'site_settings'
      expect(all_meter_attributes[1].input_data['tariff_holder']).to eq 'site_settings'
      expect(all_meter_attributes[2].input_data['tariff_holder']).to eq 'school_group'
      expect(all_meter_attributes[3].input_data['tariff_holder']).to eq 'school_group'
      expect(all_meter_attributes[4].input_data['tariff_holder']).to eq 'school'
      expect(all_meter_attributes[5].input_data['tariff_holder']).to eq 'school'
      expect(all_meter_attributes[6].input_data['tariff_holder']).to eq 'meter'
      expect(all_meter_attributes[7].input_data['tariff_holder']).to eq 'meter'
      expect(all_meter_attributes[8].input_data['tariff_holder']).to eq 'meter'
      expect(all_meter_attributes.map { |m| m.input_data['name'] }).to contain_exactly(
        energy_tariff_site_wide_electricity_both.name,
        energy_tariff_site_wide_electricity_half_hourly.name,
        energy_tariff_group_level_electricity_both.name,
        energy_tariff_group_level_electricity_half_hourly.name,
        energy_tariff_school_electricity_both.name,
        energy_tariff_school_electricity_half_hourly.name,
        meter_specific_electricity_both.name,
        meter_specific_electricity_half_hourly.name,
        meter_specific_electricity_non_half_hourly.name
      )
    end
  end
end

describe 'Meter', :meters do
  describe 'meter attributes' do
    let(:meter) { create(:electricity_meter, meter_system: :nhh_amr) }

    it 'is not pseudo by default' do
      expect(meter.pseudo).to be false
    end
  end

  describe 'scopes' do
    context 'when finding main meters' do
      let!(:electricity_meter) { create(:electricity_meter, mpan_mprn: 1_234_567_890_123) }
      let!(:electricity_meter_pseudo) { create(:electricity_meter, pseudo: true, mpan_mprn: 91_234_567_890_123) }
      let!(:gas_meter) { create(:gas_meter) }
      let!(:solar_pv_meter) { create(:solar_pv_meter) }
      let!(:exported_solar_pv_meter) { create(:exported_solar_pv_meter) }

      it 'main_meters is only real gas and electricity' do
        expect(Meter.main_meter).to contain_exactly(gas_meter, electricity_meter)
      end
    end

    context 'when finding meters for consent' do
      let(:meter_review) { create(:meter_review) }
      let(:electricity_meters_reviewed) do
        [create(:electricity_meter, dcc_meter: :smets2, meter_review:),
         create(:electricity_meter, dcc_meter: :other, meter_review:)]
      end

      before do
        create(:electricity_meter, dcc_meter: :smets2, meter_review_id: nil, consent_granted: false)
        create(:electricity_meter, dcc_meter: :no)
        create(:electricity_meter, dcc_meter: :smets2, consent_granted: true)
        create(:electricity_meter, dcc_meter: :other, consent_granted: true)
      end

      it 'awaiting_trusted_consent is only dcc meters with reviews' do
        expect(Meter.awaiting_trusted_consent).to match_array(electricity_meters_reviewed)
      end
    end

    context 'when finding meters for review' do
      let(:meter_review) { create(:meter_review) }
      let(:electricity_meters_reviewed) do
        [create(:electricity_meter, dcc_meter: :smets2, meter_review:),
         create(:electricity_meter, dcc_meter: :other, meter_review:)]
      end
      let(:electricity_meters_not_reviewed) do
        [create(:electricity_meter, dcc_meter: :smets2, meter_review_id: nil, consent_granted: false),
         create(:electricity_meter, dcc_meter: :other, meter_review_id: nil, consent_granted: false)]
      end

      before do
        create(:electricity_meter, dcc_meter: :no)
        create(:electricity_meter, dcc_meter: :smets2, consent_granted: true)
        create(:electricity_meter, dcc_meter: :other, consent_granted: true)
      end

      it 'returns a collection of reviewed meters' do
        expect(Meter.reviewed_dcc_meter).to match_array(electricity_meters_reviewed)
      end

      it 'returns a collection of unreviewed meters' do
        expect(Meter.unreviewed_dcc_meter).to match_array(electricity_meters_not_reviewed)
      end
    end

    context 'when finding meters to check against DCC' do
      it 'checks main meters' do
        meter = create(:electricity_meter, dcc_meter: :no)
        create(:electricity_meter, dcc_meter: :smets2)
        expect(Meter.meters_to_check_against_dcc.first).to eq(meter)
      end

      it 'does not check recently checked meters' do
        create(:electricity_meter, dcc_meter: :no, dcc_checked_at: 6.days.ago)
        create(:electricity_meter, dcc_meter: :smets2)
        expect(Meter.meters_to_check_against_dcc).to eq([])
      end

      it 'does not check meters for archived schools' do
        create(:electricity_meter, dcc_meter: :no, school: create(:school, active: false, removal_date: 1.month.ago))
        expect(Meter.meters_to_check_against_dcc).to eq([])
      end
    end
  end

  describe '#open_issues_count' do
    let!(:electricity_meter) { create(:electricity_meter, mpan_mprn: 1_234_567_890_123) }

    it 'returns a count of all open issues for a given meter' do
      expect(electricity_meter.open_issues_count).to eq(0)
      issue = create(:issue, issue_type: :note, status: :open)
      issue.meters << electricity_meter
      issue.save!
      expect(electricity_meter.open_issues_count).to eq(0)
      issue = create(:issue, issue_type: :issue, status: :open)
      issue.meters << electricity_meter
      issue.save!
      expect(electricity_meter.open_issues_count).to eq(1)
    end
  end

  describe 'valid?' do
    describe 'mpan_mprn' do
      context 'with an electricity meter' do
        let(:attributes) { attributes_for(:electricity_meter) }

        it 'is valid with a 13 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1_098_598_765_437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is valid with a 15 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 991_098_598_765_437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a 16 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 9_991_098_598_765_437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).not_to be_empty
        end

        it 'is invalid with a number less than 13 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).not_to be_empty
        end
      end

      context 'with a pseudo solar electricity meter' do
        let(:attributes) { attributes_for(:electricity_meter).merge(pseudo: true) }
        let!(:school)    { create(:school) }

        it 'is valid with a 14 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 91_098_598_765_437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is valid with non-standard 13 digit part' do
          meter = Meter.new(attributes.merge(mpan_mprn: 90_000_000_000_037))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number less than 14 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1234))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).not_to be_empty
        end

        it 'is invalid with a 14 digit number not beginning with 6,7,9' do
          meter = Meter.new(attributes.merge(mpan_mprn: 11_098_598_765_437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).not_to be_empty
        end

        it 'validates meter type is not changed when there is an update' do
          meter = Meter.new(attributes.merge(pseudo: true, mpan_mprn: 91_098_598_765_437, meter_type: 'electricity',
                                             school:))
          meter.valid?
          expect(meter.errors[:meter_type]).to be_empty
          meter.save!
          meter.meter_type = 'solar_pv'
          meter.valid?
          expect(meter.errors[:meter_type]).to eq(['Change of meter type is not allowed for pseudo meters'])
          meter.pseudo = 'false'
          meter.meter_type = 'solar_pv'
          meter.valid?
          expect(meter.errors[:meter_type]).to eq([])
        end

        it 'validates mpan mprn is not changed when there is an update' do
          meter = Meter.new(attributes.merge(pseudo: true, mpan_mprn: 91_098_598_765_437, meter_type: 'electricity',
                                             school:))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
          meter.save!
          meter.mpan_mprn = 91_000_000_000_037
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to eq(['Change of mpan mprn is not allowed for pseudo meters'])
          meter.pseudo = 'false'
          meter.mpan_mprn = 91_000_000_000_037
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to eq([])
        end
      end

      context 'with a solar pv meter' do
        let(:attributes) { attributes_for(:solar_pv_meter) }

        it 'is valid with a 14 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 12_345_678_901_234))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is valid with a 15 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123_456_789_012_345))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number less than 13 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123_456_789_012))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).not_to be_empty
        end

        it 'is invalid with a number more than 15 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1_234_567_890_123_456))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).not_to be_empty
        end
      end

      context 'with an exported solar pv meter' do
        let(:attributes) { attributes_for(:exported_solar_pv_meter) }

        it 'is valid with a 14 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 61_098_598_765_437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number less than 13 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123_456_789_012))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).not_to be_empty
        end
      end

      context 'with a gas meter' do
        let(:attributes) { attributes_for(:gas_meter) }

        it 'is valid with a 10 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1_098_598_765))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number longer than 15 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1_234_567_890_123_456))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).not_to be_empty
        end
      end
    end
  end

  describe '#applies_to_for_meter_system' do
    context 'for an electricity meter' do
      it 'returns which type of energy tariffs (half-hourly, non half-hourly, or both) a given meter applies to depending on the meter system set' do
        expect(build(:electricity_meter, meter_system: :nhh_amr).applies_to_for_meter_system).to eq(:non_half_hourly)
        expect(build(:electricity_meter, meter_system: :nhh).applies_to_for_meter_system).to eq(:non_half_hourly)
        expect(build(:electricity_meter,
                     meter_system: :smets2_smart).applies_to_for_meter_system).to eq(:non_half_hourly)
        expect(build(:electricity_meter, meter_system: :hh).applies_to_for_meter_system).to eq(:half_hourly)
      end
    end

    context 'for a gas meter' do
      it 'always returns both types of energy tariffs a given meter applies to irrespective of the meter system set' do
        expect(build(:gas_meter, meter_system: :nhh_amr).applies_to_for_meter_system).to eq(:both)
        expect(build(:gas_meter, meter_system: :nhh).applies_to_for_meter_system).to eq(:both)
        expect(build(:gas_meter, meter_system: :smets2_smart).applies_to_for_meter_system).to eq(:both)
        expect(build(:gas_meter, meter_system: :hh).applies_to_for_meter_system).to eq(:both)
      end
    end
  end

  describe 'correct_mpan_check_digit?' do
    it 'returns true if the check digit matches' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2_040_015_001_169)
      expect(meter.correct_mpan_check_digit?).to be(true)
    end

    it 'returns true if the check digit matches ignoring prepended digit for electricity meters' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 92_040_015_001_169)
      expect(meter.correct_mpan_check_digit?).to be(true)
    end

    it 'returns true if the check digit matches ignoring 2 prepended digits for electricity meters' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 992_040_015_001_169)
      expect(meter.correct_mpan_check_digit?).to be(true)
    end

    it 'returns false if the check digit does not match' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2_040_015_001_165)
      expect(meter.correct_mpan_check_digit?).to be(false)
    end

    it 'returns false if the mpan is short' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2_040_015_165)
      expect(meter.correct_mpan_check_digit?).to be(false)
    end
  end

  context 'with amr validated readings' do
    let(:meter) { create(:electricity_meter) }

    context 'with dates' do
      let(:base_date) { Time.zone.today - 1.year }

      before do
        create(:amr_validated_reading, meter:, reading_date: base_date)
        create(:amr_validated_reading, meter:, reading_date: base_date + 2.days)
        create(:amr_validated_reading, meter:, reading_date: base_date + 4.days)
      end

      describe '#last_validated_reading' do
        it 'finds latest reading' do
          expect(meter.last_validated_reading).to eql(base_date + 4.days)
        end
      end

      describe '#first_validated_reading' do
        it 'finds first reading' do
          expect(meter.first_validated_reading).to eql(base_date)
        end
      end
    end

    context 'with statuses' do
      let(:base_date) { Time.zone.today - 2.years }

      before do
        create(:amr_validated_reading, meter:, reading_date: base_date - 2.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter:, reading_date: base_date - 1.day, status: 'ORIG')
        create(:amr_validated_reading, meter:, reading_date: base_date, status: 'ORIG')
        create(:amr_validated_reading, meter:, reading_date: base_date + 1.day, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter:, reading_date: base_date + 2.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter:, reading_date: base_date + 3.days, status: 'ORIG')
        create(:amr_validated_reading, meter:, reading_date: base_date + 4.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter:, reading_date: base_date + 5.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter:, reading_date: base_date + 6.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter:, reading_date: base_date + 7.days, status: 'ORIG')
      end

      describe '#modified_validated_readings' do
        it 'finds only non-ORIG readings in last 2 years' do
          expect(meter.modified_validated_readings.count).to eq(5)
        end
      end

      describe '#gappy_validated_readings' do
        it 'finds gap in ORIG readings' do
          gaps = meter.gappy_validated_readings(2)
          expect(gaps.count).to be(2)
          gap = gaps.first
          expect(gap.first.reading_date).to eql(base_date + 1.day)
          expect(gap.last.reading_date).to eql(base_date + 2.days)
          gap = gaps.last
          expect(gap.first.reading_date).to eql(base_date + 4.days)
          expect(gap.last.reading_date).to eql(base_date + 6.days)
        end
      end
    end
  end

  describe '.all_meter_attributes' do
    let(:school_group)    { create(:school_group) }
    let(:school)          { create(:school, school_group:) }
    let(:meter)           { create(:electricity_meter, school:) }

    let(:all_meter_attributes) { meter.all_meter_attributes }

    context 'when there are tariffs stored as EnergyTariffs' do
      let!(:energy_tariff_site_wide_electricity_both) do
        create(:energy_tariff, :with_flat_price, tariff_holder: SiteSettings.current, applies_to: :both)
      end
      let!(:energy_tariff_site_wide_electricity_non_half_hourly) do
        create(:energy_tariff, :with_flat_price, tariff_holder: SiteSettings.current, applies_to: :non_half_hourly)
      end
      let!(:energy_tariff_site_wide_electricity_half_hourly) do
        create(:energy_tariff, :with_flat_price, tariff_holder: SiteSettings.current, applies_to: :half_hourly)
      end

      let!(:energy_tariff_group_level_electricity_both) do
        create(:energy_tariff, :with_flat_price, tariff_holder: school_group, applies_to: :both)
      end
      let!(:energy_tariff_group_level_electricity_non_half_hourly) do
        create(:energy_tariff, :with_flat_price, tariff_holder: school_group, applies_to: :non_half_hourly)
      end
      let!(:energy_tariff_group_level_electricity_half_hourly) do
        create(:energy_tariff, :with_flat_price, tariff_holder: school_group, applies_to: :half_hourly)
      end

      let!(:energy_tariff_school_electricity_both) do
        create(:energy_tariff, :with_flat_price, tariff_holder: school, applies_to: :both)
      end
      let!(:energy_tariff_school_electricity_non_half_hourly) do
        create(:energy_tariff, :with_flat_price, tariff_holder: school, applies_to: :non_half_hourly)
      end
      let!(:energy_tariff_school_electricity_half_hourly) do
        create(:energy_tariff, :with_flat_price, tariff_holder: school, applies_to: :half_hourly)
      end

      context 'and there are meter specific tariffs' do
        let!(:meter_specific_electricity_both) do
          create(:energy_tariff, :with_flat_price, tariff_holder: school, meters: [meter], applies_to: :both)
        end
        let!(:meter_specific_electricity_both_disabled) do
          create(:energy_tariff, :with_flat_price, tariff_holder: school, meters: [meter], applies_to: :both,
                                                   enabled: false)
        end
        let!(:meter_specific_electricity_half_hourly) do
          create(:energy_tariff, :with_flat_price, tariff_holder: school, meters: [meter], applies_to: :half_hourly)
        end
        let!(:meter_specific_electricity_non_half_hourly) do
          create(:energy_tariff, :with_flat_price, tariff_holder: school, meters: [meter], applies_to: :non_half_hourly)
        end

        it_behaves_like 'a meter with a non half hourly meter system', :electricity, %i[nhh_amr nhh smets2_smart]
        it_behaves_like 'a meter with a half hourly meter system', :electricity, [:hh]
      end

      it 'includes inherited tariffs with the parent filtered by the meters meter_system (non_half_hourly)' do
        expect(all_meter_attributes.map { |attributes| attributes.input_data.slice('name', 'tariff_holder') }).to \
          contain_exactly(
            { 'name' => energy_tariff_site_wide_electricity_both.name, 'tariff_holder' => 'site_settings' },
            { 'name' => energy_tariff_site_wide_electricity_non_half_hourly.name, 'tariff_holder' => 'site_settings' },
            { 'name' => energy_tariff_group_level_electricity_both.name, 'tariff_holder' => 'school_group' },
            { 'name' => energy_tariff_group_level_electricity_non_half_hourly.name, 'tariff_holder' => 'school_group' },
            { 'name' => energy_tariff_school_electricity_both.name, 'tariff_holder' => 'school' },
            { 'name' => energy_tariff_school_electricity_non_half_hourly.name, 'tariff_holder' => 'school' }
          )
      end
    end
  end

  describe '#has_solar_array?' do
    let!(:meter) { create(:electricity_meter) }

    context 'with no array' do
      it { expect(meter.has_solar_array?).to eq(false) }
    end

    context 'with metered solar' do
      before do
        create(:solar_pv_mpan_meter_mapping, meter: meter)
      end

      it { expect(meter.has_solar_array?).to eq(true) }
    end

    context 'with estimated solar' do
      before do
        create(:solar_pv_attribute, meter: meter)
      end

      it { expect(meter.has_solar_array?).to eq(true) }
    end
  end
end

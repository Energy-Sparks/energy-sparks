require 'rails_helper'

describe 'Meter', :meters do
  describe 'meter attributes' do
    let(:meter) { build(:electricity_meter) }

    it 'is not pseudo by default' do
      expect(meter.pseudo).to be false
    end

  end

  describe 'scopes' do
    context 'when finding main meters' do
      let!(:electricity_meter) { create(:electricity_meter, mpan_mprn: 1234567890123) }
      let!(:electricity_meter_pseudo) { create(:electricity_meter, pseudo: true, mpan_mprn: 91234567890123) }
      let!(:gas_meter) { create(:gas_meter) }
      let!(:solar_pv_meter) { create(:solar_pv_meter) }
      let!(:exported_solar_pv_meter) { create(:exported_solar_pv_meter) }

      it 'main_meters is only real gas and electricity' do
        expect(Meter.main_meter).to match_array([gas_meter, electricity_meter])
      end
    end

    context 'when finding meters for consent' do
      let(:meter_review) { create(:meter_review) }
      let(:electricity_meter_reviewed) { create(:electricity_meter, dcc_meter: true, meter_review: meter_review, mpan_mprn: 1234567890111) }
      let(:electricity_meter_not_reviewed) { create(:electricity_meter, dcc_meter: true, mpan_mprn: 1234567890222, meter_review_id: nil, consent_granted: false) }
      let(:electricity_meter_not_dcc) { create(:electricity_meter, dcc_meter: false, mpan_mprn: 1234567890333) }
      let(:electricity_meter_consent_granted_already) { create(:electricity_meter, dcc_meter: true, consent_granted: true, mpan_mprn: 1234567890444) }

      it 'awaiting_trusted_consent is only dcc meters with reviews' do
        expect(Meter.awaiting_trusted_consent).to match_array([electricity_meter_reviewed])
      end
    end

    context 'when finding meters for review' do
      let(:meter_review) { create(:meter_review) }
      let(:electricity_meter_reviewed) { create(:electricity_meter, dcc_meter: true, meter_review: meter_review, mpan_mprn: 1234567890111) }
      let(:electricity_meter_not_reviewed) { create(:electricity_meter, dcc_meter: true, mpan_mprn: 1234567890222, meter_review_id: nil, consent_granted: false) }
      let(:electricity_meter_not_dcc) { create(:electricity_meter, dcc_meter: false, mpan_mprn: 1234567890333) }
      let(:electricity_meter_consent_granted_already) { create(:electricity_meter, dcc_meter: true, consent_granted: true, mpan_mprn: 1234567890444) }

      it 'returns a collection of reviewed meters' do
        expect(Meter.reviewed_dcc_meter).to match_array([electricity_meter_reviewed])
      end

      it 'returns a collection of unreviewed meters' do
        expect(Meter.unreviewed_dcc_meter).to match_array([electricity_meter_not_reviewed])
      end
    end
  end

  describe '#open_issues_count' do
    let!(:electricity_meter) { create(:electricity_meter, mpan_mprn: 1234567890123) }

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

        let(:attributes) {attributes_for(:electricity_meter)}

        it 'is valid with a 13 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is valid with a 15 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 991098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a 16 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 9991098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

        it 'is invalid with a number less than 13 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

      end

      context 'with a pseudo solar electricity meter' do

        let(:attributes) { attributes_for(:electricity_meter).merge(pseudo: true) }
        let!(:school)    { create(:school) }

        it 'is valid with a 14 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 91098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is valid with non-standard 13 digit part' do
          meter = Meter.new(attributes.merge(mpan_mprn: 90000000000037))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number less than 14 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1234))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

        it 'is invalid with a 14 digit number not beginning with 6,7,9' do
          meter = Meter.new(attributes.merge(mpan_mprn: 11098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

        it 'validates meter type is not changed when there is an update' do
          meter = Meter.new(attributes.merge(pseudo: true, mpan_mprn: 91098598765437, meter_type: 'electricity', school: school))
          meter.valid?
          expect(meter.errors[:meter_type]).to be_empty
          meter.save!
          meter.meter_type = 'solar_pv'
          meter.valid?
          expect(meter.errors[:meter_type]).to eq(["Change of meter type is not allowed for pseudo meters"])
          meter.pseudo = 'false'
          meter.meter_type = 'solar_pv'
          meter.valid?
          expect(meter.errors[:meter_type]).to eq([])
        end

        it 'validates mpan mprn is not changed when there is an update' do
          meter = Meter.new(attributes.merge(pseudo: true, mpan_mprn: 91098598765437, meter_type: 'electricity', school: school))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
          meter.save!
          meter.mpan_mprn = 91000000000037
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to eq(["Change of mpan mprn is not allowed for pseudo meters"])
          meter.pseudo = 'false'
          meter.mpan_mprn = 91000000000037
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to eq([])
        end
      end

      context 'with a solar pv meter' do

        let(:attributes) {attributes_for(:solar_pv_meter)}

        it 'is valid with a 14 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 12345678901234))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is valid with a 15 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123456789012345))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number less than 13 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123456789012))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

        it 'is invalid with a number more than 15 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1234567890123456))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

      end

      context 'with an exported solar pv meter' do

        let(:attributes) {attributes_for(:exported_solar_pv_meter)}

        it 'is valid with a 14 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 61098598765437))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number less than 13 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 123456789012))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

      end

      context 'with a gas meter' do
        let(:attributes) {attributes_for(:gas_meter)}

        it 'is valid with a 10 digit number' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1098598765))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to be_empty
        end

        it 'is invalid with a number longer than 15 digits' do
          meter = Meter.new(attributes.merge(mpan_mprn: 1234567890123456))
          meter.valid?
          expect(meter.errors[:mpan_mprn]).to_not be_empty
        end

      end
    end
  end

  describe 'correct_mpan_check_digit?' do
    it 'returns true if the check digit matches' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015001169)
      expect(meter.correct_mpan_check_digit?).to eq(true)
    end

    it 'returns true if the check digit matches ignoring prepended digit for electricity meters' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 92040015001169)
      expect(meter.correct_mpan_check_digit?).to eq(true)
    end

    it 'returns true if the check digit matches ignoring 2 prepended digits for electricity meters' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 992040015001169)
      expect(meter.correct_mpan_check_digit?).to eq(true)
    end

    it 'returns false if the check digit does not match' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015001165)
      expect(meter.correct_mpan_check_digit?).to eq(false)
    end

    it 'returns false if the mpan is short' do
      meter = Meter.new(meter_type: :electricity, mpan_mprn: 2040015165)
      expect(meter.correct_mpan_check_digit?).to eq(false)
    end
  end

  context 'with amr validated readings' do

    let(:meter) { create(:electricity_meter) }

    context 'with dates' do

      let(:base_date) { Date.today - 1.years }

      before do
        create(:amr_validated_reading, meter: meter, reading_date: base_date)
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 2.days)
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 4.days)
      end

      describe '#last_validated_reading' do
        it "should find latest reading" do
          expect(meter.last_validated_reading).to eql(base_date + 4.days)
        end
      end

      describe '#first_validated_reading' do
        it "should find first reading" do
          expect(meter.first_validated_reading).to eql(base_date)
        end
      end
    end

    context 'with statuses' do

      let(:base_date) { Date.today - 2.years }

      before do
        create(:amr_validated_reading, meter: meter, reading_date: base_date - 2.day, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date - 1.day, status: 'ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date, status: 'ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 1.day, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 2.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 3.days, status: 'ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 4.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 5.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 6.days, status: 'NOT_ORIG')
        create(:amr_validated_reading, meter: meter, reading_date: base_date + 7.days, status: 'ORIG')
      end

      describe '#modified_validated_readings' do
        it "should find only non-ORIG readings in last 2 years" do
          expect(meter.modified_validated_readings.count).to eq(5)
        end
      end

      describe '#gappy_validated_readings' do
        it "should find gap in ORIG readings" do
          gaps = meter.gappy_validated_readings(2)
          expect(gaps.count).to eql(2)
          gap = gaps.first
          expect(gap.first.reading_date).to eql(base_date + 1.days)
          expect(gap.last.reading_date).to eql(base_date + 2.days)
          gap = gaps.last
          expect(gap.first.reading_date).to eql(base_date + 4.days)
          expect(gap.last.reading_date).to eql(base_date + 6.days)
        end
      end
    end
  end

  describe ".to_csv" do
    let(:data_source) { create(:data_source) }
    subject { data_source.meters.to_csv }
    let(:header) { "School group,School,MPAN/MPRN,Meter type,Active,First validated meter reading,Last validated meter reading,Admin Meter Status,Open issues" }
    before { Timecop.freeze }
    after { Timecop.return }

    context "with meters" do
      let(:admin_meter_status) { AdminMeterStatus.create(label: "On Data Feed") }
      let!(:meters) do
        [ create(:gas_meter, data_source: data_source, school: create(:school), admin_meter_status: admin_meter_status),
          create(:gas_meter, data_source: data_source, school: create(:school, :with_school_group), admin_meter_status: admin_meter_status) ]
      end
      let(:first_reading_date) { 1.year.ago.to_date + 2.days }
      let(:last_reading_date) { 1.year.ago.to_date + 4.days }

      before do
        meters.each do |meter|
          create(:amr_validated_reading, meter: meter, reading_date: first_reading_date)
          create(:amr_validated_reading, meter: meter, reading_date: last_reading_date)

          issue = create(:issue, issue_type: :issue, status: :open)
          issue.meters << meter
          issue.save!
        end
      end

      it { expect(subject.lines.count).to eq(3) }
      it { expect(subject.lines.first.chomp).to eq(header) }
      2.times do |i|
        it { expect(subject.lines[i+1].chomp).to eq([
          meters[i].school.school_group.try(:name), meters[i].school.name, meters[i].mpan_mprn,
          meters[i].meter_type.humanize, meters[i].active, first_reading_date, last_reading_date, admin_meter_status.label, 1].join(',')) }
      end
    end

    context "with meters for other data source" do
      let!(:meters) do
        [ create(:gas_meter),
          create(:gas_meter) ]
      end
      it { expect(subject.lines.count).to eq(1) }
    end

    context "with no meters" do
      it { expect(subject.lines.count).to eq(1) }
      it { expect(subject.lines.first.chomp).to eq(header) }
    end
  end
end

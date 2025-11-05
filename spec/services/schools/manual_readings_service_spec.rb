# frozen_string_literal: true

require 'rails_helper'

describe Schools::ManualReadingsService do
  subject(:service) { described_class.new(school) }

  let(:school) { create(:school) }

  describe '#show_on_menu?' do
    context 'with no fuel configuration' do
      it { is_expected.to be_show_on_menu }
    end

    context 'with fuel configuration with too recent start date' do
      let(:school) { create(:school, :with_meter_dates) }

      it { is_expected.to be_show_on_menu }
    end

    context 'with fuel configuration with too old end date' do
      let(:school) { create(:school, :with_meter_dates, reading_end_date: 1.month.ago) }

      it { is_expected.to be_show_on_menu }
    end

    context 'with fuel configuration with enough months' do
      let(:school) { create(:school, :with_meter_dates, reading_start_date: 13.months.ago) }

      it { is_expected.not_to be_show_on_menu }
    end

    context 'with a complete target' do
      let(:school) { create(:school_target, :with_monthly_consumption).school }

      it { is_expected.not_to be_show_on_menu }
    end

    context 'with a previous months incomplete target' do
      let(:school) { create(:school_target, :with_monthly_consumption, previous_missing: true).school }

      it { is_expected.to be_show_on_menu }
    end

    context 'with a current months incomplete target' do
      let(:school) { create(:school_target, :with_monthly_consumption, current_missing: true).school }

      it { is_expected.not_to be_show_on_menu }
    end

    context 'with a current months incomplete target started two month ago' do
      let(:school) do
        create(:school_target, :with_monthly_consumption, current_missing: true, start_date: 2.months.ago).school
      end

      it { is_expected.to be_show_on_menu }
    end

    context 'with existing manual readings' do
      let(:school) { create(:manual_reading, gas: 1).school }

      it { is_expected.to be_show_on_menu }
    end

    context 'with enough electricity but not gas' do
      before do
        school.configuration.update!(aggregate_meter_dates: { electricity: { start_date: 13.months.ago.to_date.iso8601,
                                                                             end_date: Date.current.iso8601 },
                                                              gas: { start_date: 1.month.ago.to_date.iso8601,
                                                                    end_date: Date.current.iso8601 } })
      end

      it { is_expected.to be_show_on_menu }
    end
  end
end

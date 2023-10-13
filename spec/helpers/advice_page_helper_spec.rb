require 'rails_helper'

describe AdvicePageHelper do
  let(:school)                    { create(:school) }
  let(:advice_page)               { create(:advice_page, key: 'baseload') }
  let(:advice_page_not_in_routes) { create(:advice_page, key: 'notapage') }

  describe '.compare_for_school_group_path' do
    it 'returns a path to the compare page for a specific benchmark_type and for a school with no school group' do
      expect(compare_for_school_group_path(:baseload_per_pupil, school)).to eq('/compare/baseload_per_pupil')
    end

    it 'returns a path to the compare page for a specific benchmark_type and for a school with a school group' do
      allow_any_instance_of(School).to receive(:school_group) { OpenStruct.new(id: 999) }
      expect(compare_for_school_group_path(:baseload_per_pupil, school)).to eq('/compare/baseload_per_pupil?school_group_ids%5B%5D=999')
    end
  end

  describe '.format_unit' do
    it 'formats a value accourding to its energy unit and the unit symbol as an html character reference' do
      expect(helper.format_unit(1234567, :co2)).to eq("1,234,567")
      expect(helper.format_unit(-4.736951571734001e-15, :co2)).to eq("0")
      expect(helper.format_unit(1234567, :kwh)).to eq("1,234,567")
      expect(helper.format_unit(-4.736951571734001e-15, :kwh)).to eq("0")
      expect(helper.format_unit(1234567, :£)).to eq("&pound;1,234,567")
      expect(helper.format_unit(0, :£)).to eq("0p")
      expect(helper.format_unit(-4.736951571734001e-15, :£)).to eq("0p")
      expect(helper.format_unit(1234567, :percent)).to eq("120,000,000&percnt;")
      expect(helper.format_unit(-4.736951571734001e-15, :percent)).to eq("0&percnt;")
      expect(helper.format_unit(0, :percent)).to eq("0&percnt;")
    end
  end

  describe '.advice_baseload_high?' do
    it 'returns true if value higher than 0.0' do
      expect(helper.advice_baseload_high?(0.1)).to be_truthy
    end
    it 'returns false if value less than 0.0' do
      expect(helper.advice_baseload_high?(-0.1)).to be_falsey
    end
    it 'returns false if value equals 0.0' do
      expect(helper.advice_baseload_high?(0.0)).to be_falsey
    end
  end

  describe '.chart_start_month_year' do
    it 'returns month and year' do
      expect(helper.chart_start_month_year(Date.parse('20210101'))).to eq('December 2019')
    end
  end

  describe '.chart_end_month_year' do
    it 'returns month and year' do
      expect(helper.chart_end_month_year(Date.parse('20210101'))).to eq('December 2020')
    end
  end

  describe '#months_between' do
    it 'calculates the floored number of months between two dates' do
      expect(helper.months_between((Date.new(2022, 12, 31) - 2.years), Date.new(2022, 12, 31))).to eq(24)
      expect(helper.months_between((Date.new(2022, 12, 31) - 2.years + 1.day), Date.new(2022, 12, 31))).to eq(23)
    end
  end

  describe '.advice_page_path' do
    it 'returns path to insights by default' do
      expect(helper.advice_page_path(school, advice_page)).to end_with("/schools/#{school.slug}/advice/baseload/insights")
    end

    it 'returns path to insights tab' do
      expect(helper.advice_page_path(school, advice_page, :insights)).to end_with("/schools/#{school.slug}/advice/baseload/insights")
    end

    it 'returns path to analysis tab' do
      expect(helper.advice_page_path(school, advice_page, :analysis)).to end_with("/schools/#{school.slug}/advice/baseload/analysis")
    end

    it 'errors if advice page is not legit' do
      expect do
        helper.advice_page_path(school, advice_page_not_in_routes)
      end.to raise_error(NoMethodError)
    end

    it 'errors if tab is not legit' do
      expect do
        helper.advice_page_path(school, advice_page, :blah)
      end.to raise_error(NoMethodError)
    end
  end

  describe '.sort_by_label' do
    before :each do
      I18n.backend.store_translations("en", { advice_pages: { nav: { pages: { one: "ZZZ", two: "AAA" } } } })
      I18n.backend.store_translations("cy", { advice_pages: { nav: { pages: { one: "AAA", two: "ZZZ" } } } })
    end
    let(:advice_page_1) { create(:advice_page, key: 'one') }
    let(:advice_page_2) { create(:advice_page, key: 'two') }
    let(:advice_pages) { [advice_page_1, advice_page_2] }
    it 'sorts by default label' do
      sorted_advice_pages = helper.sort_by_label(advice_pages)
      expect(sorted_advice_pages.map(&:key)).to eq(%w[two one])
    end
    it 'sorts by cy label' do
      I18n.with_locale(:cy) do
        sorted_advice_pages = helper.sort_by_label(advice_pages)
        expect(sorted_advice_pages.map(&:key)).to eq(%w[one two])
      end
    end
  end

  describe 'with dashboard alerts' do
    let(:alert_type_advice)   { create(:alert_type, group: 'advice', class_name: 'AdviceAlert') }
    let(:alert_type_change)   { create(:alert_type, group: 'change', class_name: 'ChangeAlert') }
    let(:alert_advice) { create(:alert, :with_run, alert_type: alert_type_advice, run_on: Time.zone.today, school: school, rating: 9.0) }
    let(:alert_change) { create(:alert, :with_run, alert_type: alert_type_change, run_on: Time.zone.today, school: school, rating: 9.0) }
    let(:dashboard_alert_advice)  { OpenStruct.new(alert: alert_advice) }
    let(:dashboard_alert_change)  { OpenStruct.new(alert: alert_change) }
    let(:dashboard_alerts) { [dashboard_alert_advice, dashboard_alert_change] }

    describe '.dashboard_alert_groups' do
      it 'should return list of groups with alerts' do
        expect(helper.dashboard_alert_groups(dashboard_alerts)).to eq(%w[change advice])
      end
    end

    describe '.dashboard_alerts_for_group' do
      it 'should return alerts for group' do
        expect(helper.dashboard_alerts_for_group(dashboard_alerts, 'change')).to eq([dashboard_alert_change])
      end
    end

    describe '.alert_types_for_group' do
      it 'should return alert types for group' do
        expect(helper.alert_types_for_group('change')).to eq([alert_type_change])
      end
      it 'handles unknown group' do
        expect(helper.alert_types_for_group('blah')).to eq([])
      end
    end

    describe '.alert_types_for_class' do
      it 'should return alert types for class name' do
        expect(helper.alert_types_for_class('ChangeAlert')).to eq([alert_type_change])
      end
    end
  end
end

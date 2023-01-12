require 'rails_helper'

describe AdvicePageHelper do

  let(:school)                    { create(:school) }
  let(:advice_page)               { create(:advice_page, key: 'baseload') }
  let(:advice_page_not_in_routes) { create(:advice_page, key: 'notapage') }

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

  describe '.advice_page_path' do

    it 'returns path to show' do
      expect(helper.advice_page_path(school, advice_page)).to end_with("/schools/#{school.slug}/advice/baseload")
    end

    it 'returns path to insights tab' do
      expect(helper.advice_page_path(school, advice_page, :insights)).to end_with("/schools/#{school.slug}/advice/baseload/insights")
    end

    it 'returns path to analysis tab' do
      expect(helper.advice_page_path(school, advice_page, :analysis)).to end_with("/schools/#{school.slug}/advice/baseload/analysis")
    end

    it 'errors if advice page is not legit' do
      expect {
        helper.advice_page_path(school, advice_page_not_in_routes)
      }.to raise_error(NoMethodError)
    end

    it 'errors if tab is not legit' do
      expect {
        helper.advice_page_path(school, advice_page, :blah)
      }.to raise_error(NoMethodError)
    end

  end
end

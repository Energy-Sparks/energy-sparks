# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Meters::ReadingCalendarComponent, :include_application_helper, :include_url_helpers, type: :component do
  shared_examples 'a rendered reading calendar' do
    it { expect(page).to have_css('div.readings-calendar') }
    it { expect(page).to have_css("div[data-url='#{path}']") }
    it { expect(page).to have_css('div.calendar-legend') }
    it { expect(page).to have_css('.legend-label') }
  end

  let!(:meter) { create(:electricity_meter_with_validated_reading_dates) }

  context 'with a detailed view' do
    subject(:component) do
      described_class.new(meter:,
                          calendar_generator: Meters::DetailedCalendarGenerator.new(meter),
                          path:)
    end

    let(:path) { admin_reports_amr_validated_reading_path(meter, format: :json) }

    before { render_inline component }

    it_behaves_like 'a rendered reading calendar'
  end

  context 'with a summary view' do
    subject(:component) do
      described_class.new(meter:,
                          calendar_generator: Meters::SummarisedCalendarGenerator.new(meter),
                          path:)
    end

    let(:path) { admin_reports_amr_validated_reading_summary_path(meter, format: :json) }

    before { render_inline component }

    it_behaves_like 'a rendered reading calendar'
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schools::UtilityStatusComponent, type: :component do
  subject(:component) { described_class.new(school:) }

  before do
    render_inline component
  end

  context 'when not data enabled' do
    let(:school) { create(:school, :with_meter_dates, data_enabled: false) }

    it { expect(page).to have_css('span.text-bg-danger') }

    it { expect(page).to have_text('Not data visible') }
  end

  shared_examples 'with a no data message' do
    it { expect(page).to have_css('span.text-bg-danger') }
    it { expect(page).to have_text('No data') }
  end

  context 'when data enabled' do
    context 'with no configuration' do
      let(:school) do
        school = create(:school, process_data: true)
        school.configuration.destroy
        school.reload
      end

      it_behaves_like 'with a no data message'
    end

    context 'when not processing data' do
      let(:school) { create(:school, process_data: false) }

      it_behaves_like 'with a no data message'
    end

    context 'with no meter dates' do
      let(:school) { create(:school) }

      it_behaves_like 'with a no data message'
    end

    context 'with single fuel type' do
      let(:school) { create(:school, :with_meter_dates) }

      context 'with up to date data' do
        it { expect(page).to have_css('span.text-bg-success') }

        it { expect(page).to have_text('All utilities') }
      end

      context 'with lagging data' do
        let(:school) { create(:school, :with_meter_dates, reading_end_date: 14.days.ago) }

        it { expect(page).to have_css('span.text-bg-danger') }
        it { expect(page).to have_text('No recent data') }
      end
    end
  end
end

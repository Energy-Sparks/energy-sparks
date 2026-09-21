# frozen_string_literal: true

require 'rails_helper'

describe 'Stale data report' do
  let(:school) { create(:school, :with_school_group) }
  let!(:meter) do
    create(:gas_meter_with_validated_reading_dates,
           school:, data_source: create(:data_source), supplier: create(:supplier), admin_meter_status:
           create(:admin_meter_status))
  end

  before do
    sign_in(create(:admin))
    visit admin_reports_path
    click_on 'Meters with stale data'
  end

  it_behaves_like 'an admin meter report', help: false do
    let(:title) { 'Meters with stale data' }
    let(:description) { 'List of active meters where validated data is more than 30 days old' }
  end

  it_behaves_like 'an admin meter import report' do
    let(:end_date) { meter.amr_validated_readings.maximum(:reading_date) }
  end
end

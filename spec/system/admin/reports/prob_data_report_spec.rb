require 'rails_helper'

describe 'Prob Data Report', type: :system do
  let!(:school) { create(:school, :with_school_group) }

  let!(:meter) do
    create(:gas_meter_with_validated_reading_dates,
      school: school,
      start_date: Time.zone.today - 5,
      end_date: Time.zone.today,
      status: 'PROB')
  end

  before do
    sign_in(create(:admin))
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'displays expected data' do
    click_on 'PROB data report'
    expect(page).to have_content('PROB data report')

    expect(all('#report tr').map { |tr| tr.all('th,td').map(&:text) }).to eq([
                                                                               ['School group', 'School', 'Meter name', 'MPXN', 'Meter type', 'Count'],
                                                                               [
                                                                                 school.school_group.name,
                                                                                 school.name,
                                                                                 meter.name,
                                                                                 meter.mpan_mprn.to_s,
                                                                                 meter.meter_type,
                                                                                 '6'
                                                                               ]
                                                                             ])
  end
end

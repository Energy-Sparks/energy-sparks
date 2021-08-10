require 'rails_helper'

RSpec.describe "school alerts", type: :system do
  let!(:school) { create(:school) }
  let!(:user)  { create(:staff, staff_role: create(:staff_role, :teacher), school: school)}
  let(:description) { 'all about this alert type' }
  let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :termly, description: description) }
  let(:gas_date) { Date.parse('2019-01-01') }
  let!(:gas_meter) { create :gas_meter_with_reading, school_id: school.id }

  before(:each) do
    sign_in(user)
  end

  context 'with generated alert' do

    describe 'Find Out More' do

      let!(:activity_type){ create(:activity_type, name: 'Turn off the heating') }
      let!(:alert_type_rating) do
        create(
          :alert_type_rating,
          alert_type: gas_fuel_alert_type,
          rating_from: 0,
          rating_to: 10,
          find_out_more_active: true,
          management_dashboard_alert_active: true,
          teacher_dashboard_alert_active: true,
          pupil_dashboard_alert_active: true,
          activity_types: [activity_type]
        )
      end
      let!(:alert_type_rating_content_version) do
        create(
          :alert_type_rating_content_version,
          alert_type_rating: alert_type_rating,
          management_dashboard_title: 'Your heating is on!',
          teacher_dashboard_title: 'Your heating is on!',
          pupil_dashboard_title: 'It is too warm',
          find_out_more_title: 'You might want to think about heating',
          find_out_more_content: 'This is what you need to do',
          find_out_more_table_variable: 'dummy_table'
        )
      end
      let(:alert_summary){ 'Summary of the alert' }
      let!(:alert) do
        create(:alert, :with_run,
          alert_type: gas_fuel_alert_type,
          run_on: gas_date, school: school,
          rating: 9.0,
          table_data: {
            dummy_table: [['Header 1', 'Header 2'], ['Body 1', 'Body 2']]
          }
        )
      end

      before do
        Alerts::GenerateContent.new(school).perform
      end

      it 'can show a single alert with the associated activities' do
        visit root_path

        expect(page).to have_content('Your heating is on!')
        #expect(page).to have_content("Turn off the heating")

        click_on("Find out more")

        expect(page).to have_content('You might want to think about heating')
        expect(page).to have_content('This is what you need to do')
        expect(page).to have_content(activity_type.name)

        expect(page).to have_selector('table', text: 'Body 1')

      end

      it 'shows find out more alerts on the pupil dashboard' do
        visit root_path
        click_on 'Pupil dashboard'

        expect(page).to have_content('It is too warm')
      end
    end
  end

end

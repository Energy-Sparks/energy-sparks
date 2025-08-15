require 'rails_helper'

RSpec.describe 'alert type management', type: :system do
  let!(:admin) { create(:admin)}

  let(:gas_fuel_alert_type_title) { 'Your gas usage is too high' }
  let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :termly, title: gas_fuel_alert_type_title, has_ratings: has_ratings) }
  let(:has_ratings) { true }


  describe 'managing associated activities' do
    let!(:alert_type_rating) { create(:alert_type_rating, alert_type: gas_fuel_alert_type)}
    let!(:activity_category) { create(:activity_category)}
    let!(:activity_type_1) { create(:activity_type, name: 'Turn off the lights', activity_category: activity_category)}
    let!(:activity_type_2) { create(:activity_type, name: 'Turn down the heating', activity_category: activity_category)}

    let!(:intervention_type_group) { create(:intervention_type_group) }
    let!(:intervention_type_1) { create(:intervention_type, name: 'Install cladding', intervention_type_group: intervention_type_group)}
    let!(:intervention_type_2) { create(:intervention_type, name: 'Check the boiler', intervention_type_group: intervention_type_group)}

    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      click_on 'Alert Types'
    end

    it 'assigns intervention types to alerts via a text box position' do
      click_on gas_fuel_alert_type_title
      click_on 'Content management'
      click_on 'Actions (0)'

      expect(page.find_field('Install cladding').value).to be_blank
      expect(page.find_field('Check the boiler').value).to be_blank

      fill_in 'Check the boiler', with: '1'

      click_on 'Update associated actions', match: :first
      click_on 'Actions (1)'

      expect(page.find_field('Install cladding').value).to be_blank
      expect(page.find_field('Check the boiler').value).to eq('1')

      expect(alert_type_rating.intervention_types).to match_array([intervention_type_2])
      expect(alert_type_rating.alert_type_rating_intervention_types.first.position).to eq(1)
    end

    it 'assigns activity types to alerts via a text box position' do
      click_on gas_fuel_alert_type_title
      click_on 'Content management'

      click_on 'Activity types'

      expect(page.find_field('Turn off the light').value).to be_blank
      expect(page.find_field('Turn down the heating').value).to be_blank

      fill_in 'Turn down the heating', with: '1'

      click_on 'Update associated activity type', match: :first
      click_on 'Activity types'

      expect(page.find_field('Turn off the light').value).to be_blank
      expect(page.find_field('Turn down the heating').value).to eq('1')

      expect(alert_type_rating.activity_types).to match_array([activity_type_2])
      expect(alert_type_rating.alert_type_rating_activity_types.first.position).to eq(1)
    end
  end

  describe 'creating alert content' do
    let!(:alert) do
      create(:alert, alert_type: gas_fuel_alert_type, template_data: { gas_percentage: '10%', chart_a: :example_chart_value }, school: create(:school))
    end

    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Alert Types'
    end

    context 'with ratings' do
      it 'allows creation and editing of alert content', js: true do
        click_on gas_fuel_alert_type_title
        click_on 'Content management'

        click_on 'New content rating range'

        fill_in 'Rating from', with: '0'
        fill_in 'Rating to', with: '10'
        fill_in 'Description', with: 'For schools with bad heating management'

        select 'Negative', from: 'Colour'

        check 'Pupil dashboard alert'
        fill_in_trix with: gas_fuel_alert_type_title

        within '.pupil_dashboard_alert_active' do
          click_on 'Preview (English)'
          within '#pupil_dashboard_alert-preview-en .content' do
            expect(page).to have_content(gas_fuel_alert_type_title)
          end
        end

        check 'Adult dashboard alert'
        within('#management_dashboard_alert-en-content') do
          fill_in_trix with: 'MDASH - Your school is using gas'
        end
        within '.management_dashboard_alert_active' do
          click_on 'Content (Welsh)'
        end
        within('#management_dashboard_alert-cy-content') do
          fill_in_trix with: 'MDASH WELSH - Your school is using gas'
        end

        within '.management_dashboard_alert_active' do
          click_on 'Preview (Welsh)'
          within '#management_dashboard_alert-preview-cy .content' do
            expect(page).to have_content('MDASH WELSH - Your school is using gas')
          end
        end

        check 'Management priorities'
        fill_in_trix with: 'Your school is spending too much on gas'

        within '.management_priorities_active' do
          click_on 'Preview (English)'
          within '#management_priorities-preview-en .content' do
            expect(page).to have_content('Your school is spending too much on gas')
          end
        end

        check 'SMS content'
        fill_in 'SMS content', with: gas_fuel_alert_type_title

        within '.sms_active' do
          click_on 'Preview (English)'

          within '#sms-preview-en .content' do
            expect(page).to have_content(gas_fuel_alert_type_title)
          end
        end

        check 'Email content'
        fill_in 'Email title en', with: 'Gas usage'

        within '.email_active' do
          fill_in_trix with: 'You are using {{gas_percentage}} too much gas! You need to do something about it.'

          click_on 'Preview (English)'

          within '#email-preview-en .content' do
            expect(page).to have_content('You are using 10% too much gas!')
          end
        end

        check 'Group dashboard alert'
        within('#group_dashboard_alert-en-content') do
          fill_in_trix with: 'Content for group alert'
        end

        click_on 'Create content'

        with_retry { expect(gas_fuel_alert_type.ratings.size).to eq(1) }
        alert_type_rating = gas_fuel_alert_type.ratings.first
        expect(alert_type_rating.content_versions.size).to eq(1)
        first_content = alert_type_rating.current_content
        expect(first_content.sms_content).to eq(gas_fuel_alert_type_title)
        expect(first_content.management_dashboard_title.to_plain_text).to eq('MDASH - Your school is using gas')
        expect(first_content.management_dashboard_title(locale: :cy).to_plain_text).to eq('MDASH WELSH - Your school is using gas')
        expect(first_content.management_priorities_title.to_plain_text).to eq('Your school is spending too much on gas')
        expect(first_content.group_dashboard_title.to_plain_text).to eq('Content for group alert')

        click_on 'Edit'

        click_on 'Dummy alert'
        expect(page).to have_content('chart description A chart example_chart_value')

        fill_in 'Email title en', with: 'Stop using so much gas!'
        click_on 'Update content'

        with_retry { expect(alert_type_rating.content_versions.size).to eq(2) }
      end
    end

    context 'without ratings' do
      let(:has_ratings) { false }

      it 'does not ask for ratings and defaults them' do
        click_on gas_fuel_alert_type_title
        click_on 'Content management'

        click_on 'New content'

        fill_in 'Description', with: 'For schools with bad heating management'

        select 'Negative', from: 'Colour'

        click_on 'Create content'

        expect(gas_fuel_alert_type.ratings.size).to eq(1)
        alert_type_rating = gas_fuel_alert_type.ratings.first
        expect(alert_type_rating.rating_from).to eq(0.0)
        expect(alert_type_rating.rating_to).to eq(10.0)
      end
    end
  end
end

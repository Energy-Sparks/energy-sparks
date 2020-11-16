require 'rails_helper'

describe "activity type", type: :system do

  let!(:admin)  { create(:admin)}
  let!(:activity_category) { create(:activity_category)}
  let!(:ks1) { KeyStage.create(name: 'KS1') }
  let!(:ks2) { KeyStage.create(name: 'KS2') }
  let!(:ks3) { KeyStage.create(name: 'KS3') }

  let!(:science){ Subject.create(name: 'Science') }
  let!(:maths){ Subject.create(name: 'Maths') }

  let!(:half_hour){ ActivityTiming.create(name: '30 mins') }
  let!(:hour){ ActivityTiming.create(name: 'Hour') }

  let!(:reducing_gas){ Impact.create(name: 'Reducing gas') }
  let!(:reducing_electricity){ Impact.create(name: 'Reducing electricity') }

  let!(:pie_charts){ Topic.create(name: 'Pie charts') }
  let!(:energy){ Topic.create(name: 'Energy') }

  describe 'when not logged in' do
    it 'does not authorise viewing' do
      visit admin_activity_types_path
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Activity Types'
      expect(ActivityType.count).to be 0
    end

    it 'can add a new activity for KS1 with filters' do
      description = 'The description'
      download_links = 'Some download links'
      school_specific_description = description + ' for SCHOOOOOOLS'
      activity_name = 'New activity'

      click_on 'New Activity Type'
      fill_in('Name', with: activity_name)

      attach_file("activity_type_image", Rails.root + "spec/fixtures/images/activity-type-placeholder.png")

      within('.download-links-trix-editor') do
        fill_in_trix with: download_links
      end

      within('.description-trix-editor') do
        fill_in_trix with: description
      end

      within('.school-specific-description-trix-editor') do
        fill_in_trix with: school_specific_description
      end

      fill_in('Score', with: 20)

      check('KS1')
      check('Science')
      check('30 mins')
      check('Reducing electricity')
      check('Energy')

      click_on('Create Activity type')

      activity_type = ActivityType.first

      expect(activity_type.key_stages).to match_array([ks1])
      expect(activity_type.subjects).to   match_array([science])
      expect(activity_type.activity_timings).to    match_array([half_hour])
      expect(activity_type.topics).to     match_array([energy])
      expect(activity_type.impacts).to    match_array([reducing_electricity])

      expect(activity_type.image.filename).to eq('activity-type-placeholder.png')

      expect(page.has_content?("Activity type was successfully created.")).to be true
      expect(ActivityType.count).to be 1

      click_on activity_name
      expect(page).to have_css("img[src*='activity-type-placeholder.png']")
      expect(page).to have_content(download_links)
      expect(page).to have_content(description)
      expect(page).to have_content(school_specific_description)
    end

    it 'can embed a chart from the analytics', js: true do
      school = create :school # for preview
      allow_any_instance_of(SchoolAggregation).to receive(:aggregate_school).and_return(school)
      allow_any_instance_of(ChartData).to receive(:data).and_return(nil)

      click_on 'New Activity Type'
      within('.school-specific-description-trix-editor') do
        fill_in_trix with: "Your chart"
        find('button[data-trix-action="chart"]').click
        select 'last_7_days_intraday_gas', from: 'chart-list-chart'
        click_on 'Insert'
        expect(find('trix-editor')).to have_text('{{#chart}}last_7_days_intraday_gas{{/chart}}')
        click_on 'Preview'
        within '#school-specific-description-preview' do
          expect(page).to have_content('Your chart')
          expect(page).to have_selector('#chart_wrapper_last_7_days_intraday_gas')
        end
      end
    end

    it 'can does not crash if you forget the score' do
      click_on 'New Activity Type'
      fill_in('Name', with: 'New activity')
      fill_in_trix with: "the description"

      check('KS1')

      click_on('Create Activity type')

      expect(page.has_content?("Score can't be blank"))

      expect(page.has_content?("Activity type was successfully created.")).to_not be true
      expect(ActivityType.count).to be 0
    end

    it 'can edit a new activity and add KS2 and KS3' do
      activity_type = create(:activity_type, activity_category: activity_category)
      refresh

      click_on 'Edit'
      expect(page.has_content?(activity_type.name)).to be true

      check('KS2')
      check('KS3')

      click_on('Update Activity type')

      activity_type.reload

      expect(activity_type.key_stages).to_not include(ks1)
      expect(activity_type.key_stages).to     include(ks2)
      expect(activity_type.key_stages).to     include(ks3)

      expect(page.has_content?("Activity type was successfully updated.")).to be true
      expect(ActivityType.count).to be 1
    end
  end
end

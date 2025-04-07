require 'rails_helper'

describe 'activity type', type: :system do
  let!(:admin) { create(:admin)}
  let!(:activity_category) { create(:activity_category)}
  let!(:ks1) { KeyStage.create(name: 'KS1') }
  let!(:ks2) { KeyStage.create(name: 'KS2') }
  let!(:ks3) { KeyStage.create(name: 'KS3') }

  let!(:science) { Subject.create(name: 'Science') }
  let!(:maths) { Subject.create(name: 'Maths') }

  let!(:half_hour) { ActivityTiming.create(name: '30 mins') }
  let!(:hour) { ActivityTiming.create(name: 'Hour') }

  let!(:reducing_gas) { Impact.create(name: 'Reducing gas') }
  let!(:reducing_electricity) { Impact.create(name: 'Reducing electricity') }

  let!(:pie_charts) { Topic.create(name: 'Pie charts') }
  let!(:energy) { Topic.create(name: 'Energy') }

  describe 'when not logged in' do
    it 'does not authorise viewing' do
      visit admin_activity_types_path
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end

  describe 'when logged in' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Activity Types'
      expect(ActivityType.count).to be 0
    end

    context 'when adding a new activity' do
      before do
        school = create :school # for preview
        allow_any_instance_of(SchoolAggregation).to receive(:aggregate_school).and_return(school)
        allow_any_instance_of(ChartData).to receive(:data).and_return(nil)

        click_on 'New Activity Type'
      end

      it 'can add a new activity for KS1 with filters' do
        description = 'The description'
        summary = 'An activity to try'
        download_links = 'Some download links'
        school_specific_description = description + ' for SCHOOOOOOLS'
        activity_name = 'New activity'

        fill_in :activity_type_name_en, with: activity_name
        fill_in :activity_type_summary_en, with: summary

        attach_file(:activity_type_image_en, Rails.root + 'spec/fixtures/images/placeholder.png')

        within('.download-links-trix-editor.en') do
          fill_in_trix with: download_links
        end

        within('.description-trix-editor.en') do
          fill_in_trix with: description
        end

        within('.school-specific-description-trix-editor.en') do
          fill_in_trix with: school_specific_description
        end

        fill_in('Score', with: 20)
        fill_in('Maximum frequency', with: 5)

        check('KS1')
        check('Science')
        check('30 mins')
        check('Reducing electricity')
        check('Energy')

        click_on('Create Activity type')

        activity_type = ActivityType.first

        expect(activity_type.summary).to eq(summary)
        expect(activity_type.key_stages).to match_array([ks1])
        expect(activity_type.subjects).to   match_array([science])
        expect(activity_type.activity_timings).to match_array([half_hour])
        expect(activity_type.topics).to     match_array([energy])
        expect(activity_type.impacts).to    match_array([reducing_electricity])
        expect(activity_type.maximum_frequency).to eq(5)
        expect(activity_type.image_en.filename).to eq('placeholder.png')

        expect(page.has_content?('Activity type was successfully created.')).to be true
        expect(ActivityType.count).to be 1

        click_on activity_name
        expect(page).to have_css("img[src*='placeholder.png']")
        expect(page).to have_content(download_links)
        expect(page).to have_content(description)
        expect(page).to have_content(school_specific_description)
      end

      it 'can does not crash if you forget the score' do
        fill_in :activity_type_name_en, with: 'New activity'
        fill_in_trix with: 'the description'

        check('KS1')

        click_on('Create Activity type')

        expect(page.has_content?("Score can't be blank"))

        expect(page.has_content?('Activity type was successfully created.')).not_to be true
        expect(ActivityType.count).to be 0
      end

      context 'when adding a chart', js: true do
        it_behaves_like 'a form with a customised trix component', charts: true
        it_behaves_like 'a trix component with a working chart button' do
          let(:chart_id) { 'last_7_days_intraday_gas' }
        end

        it 'can preview an embedded chart' do
          within('.school-specific-description-trix-editor') do
            embed = 'Your chart {{#chart}}last_7_days_intraday_gas{{/chart}}'
            fill_in_trix '#activity_type_school_specific_description_en', with: embed
            click_on 'Preview'
            within '#school-specific-description-preview-en' do
              expect(page).to have_content('Your chart')
              expect(page).to have_selector('#chart_wrapper_last_7_days_intraday_gas')
            end
          end
        end
      end
    end

    it 'can edit a new activity' do
      activity_type = create(:activity_type, activity_category: activity_category, maximum_frequency: 10)
      refresh

      click_on 'Edit'
      expect(page.has_content?(activity_type.name)).to be true

      check('KS2')
      check('KS3')
      fill_in('Maximum frequency', with: 5)

      click_on('Update Activity type')

      activity_type.reload

      expect(activity_type.key_stages).not_to include(ks1)
      expect(activity_type.key_stages).to     include(ks2)
      expect(activity_type.key_stages).to     include(ks3)
      expect(activity_type.maximum_frequency).to eq(5)

      expect(page.has_content?('Activity type was successfully updated.')).to be true
      expect(ActivityType.count).to be 1
    end

    it 'can update en and cy descriptions and show both' do
      activity_type = create(:activity_type, activity_category: activity_category)
      refresh

      click_on 'Edit'

      within('.description-trix-editor.en') do
        fill_in_trix with: 'some english description'
      end

      within('.description-trix-editor.cy') do
        fill_in_trix with: 'some welsh description'
      end

      within('.school-specific-description-trix-editor.en') do
        fill_in_trix with: 'some english school specific description'
      end

      within('.school-specific-description-trix-editor.cy') do
        fill_in_trix with: 'some welsh school specific description'
      end

      click_on('Update Activity type')

      activity_type.reload

      expect(activity_type.description(locale: :en).body.to_html).to include('some english description')
      expect(activity_type.description(locale: :cy).body.to_html).to include('some welsh description')
      expect(activity_type.school_specific_description(locale: :en).body.to_html).to include('some english school specific description')
      expect(activity_type.school_specific_description(locale: :cy).body.to_html).to include('some welsh school specific description')

      visit admin_activity_type_path(activity_type)

      expect(page).to have_content('some english description')
      expect(page).to have_content('some welsh description')
      expect(page).to have_content('some english school specific description')
      expect(page).to have_content('some welsh school specific description')
    end
  end
end

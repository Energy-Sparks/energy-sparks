require 'rails_helper'

describe 'viewing and recording activities', type: :system do

  let!(:activity_category) { create(:activity_category)}

  let!(:subject)  { Subject.create(name: "Science") }
  let!(:ks1)      { KeyStage.create(name: 'KS1') }
  let(:activity_data_driven)    { true }
  let(:school_data_enabled)     { true }

  let(:activity_type_name)           { 'Exciting activity' }
  let(:activity_description)    { "It's An #{activity_type_name}" }

  let!(:activity_type) { create(:activity_type, name: activity_type_name, activity_category: activity_category, description: activity_description, key_stages: [ks1], subjects: [subject], data_driven: activity_data_driven) }

  let!(:school) { create_active_school(data_enabled: school_data_enabled) }

  context 'as a public user' do

    before(:each) do
      visit activity_type_path(activity_type)
    end

    context 'viewing an activity type' do
      it 'should display title' do
        expect(page).to have_content(activity_type_name)
      end

      it 'should display tags' do
        expect(page).to have_content(ks1.name)
        expect(page).to have_content(subject.name)
      end

      it 'should display score' do
        expect(page).to have_content(activity_type.score)
      end

      it 'should display description' do
        expect(page).to have_content(activity_type.description.to_plain_text)
        expect(page).to_not have_content(activity_type.school_specific_description.to_plain_text)
      end

      it 'should display navigation' do
        expect(page).to have_link("View #{activity_category.activity_types.count} related activities")
      end

      it 'should display resource links' do
        expect(page).to have_content(activity_type.download_links.to_plain_text)
      end

      it 'should display prompt to login' do
        expect(page).to have_content("Are you an Energy Sparks user?")
        expect(page).to have_link("Sign in to record activity")
      end

    end

    context 'when logging in to record' do
      let!(:staff)  { create(:staff, school: school)}

      it 'should redirect back to activity after login' do
        click_on "Sign in to record activity"
        fill_in 'Email', with: staff.email
        fill_in 'Password', with: staff.password
        within '#staff' do
          click_on 'Sign in'
        end
        expect(page).to have_content(activity_type.name)
        expect(page).to have_content("Complete this activity to score your school #{activity_type.score} points!")
      end
    end
  end

  context 'as a teacher' do
    let!(:staff)  { create(:staff, school: school)}

    before(:each) do
      sign_in(staff)
      visit activity_type_path(activity_type)
    end

    context 'viewing an activity type' do
      it 'should see school specific content' do
        expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
        expect(page).to_not have_content(activity_type.description.to_plain_text)
      end

      it 'should not see prompt to login' do
        expect(page).to_not have_link("Sign in to record activity")
      end

      it 'should see prompt to record it' do
        expect(page).to have_content("Complete this activity to score your school #{activity_type.score} points!")
        expect(page).to have_link("Record this activity")
      end
    end

    context 'viewing a previously recorded activity' do
      let!(:activity)     { create(:activity, school: school, activity_type: activity_type) }

      before(:each) do
        refresh
      end

      context 'when school is data enabled' do
        it 'should see previous records' do
          expect(page).to have_content("Activity previously completed")
          expect(page).to have_content("once")
        end

        it 'should link to the activity' do
          expect(page).to have_link(href: school_activity_path(school, activity))
        end

        it 'should show school specific description' do
          visit school_activity_path(school, activity)
          expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to_not have_content(activity_type.description.to_plain_text)
        end
      end

      context 'when school not data enabled' do
        let(:school_data_enabled) { false }

        it 'should show generic description' do
          visit school_activity_path(school, activity)
          expect(page).to_not have_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to have_content(activity_type.description.to_plain_text)
        end

        context 'when activity not data driven' do
          let(:activity_data_driven)  { false }

          it 'should show school specfici description' do
            visit school_activity_path(school, activity)
            expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
            expect(page).to_not have_content(activity_type.description.to_plain_text)
          end
        end
      end

    end

    context 'recording an activity' do
      let(:activity_description) { 'What we did' }

      it 'allows an activity to be created' do
        visit activity_type_path(activity_type)

        click_on 'Record this activity'
        expect(find_field(:activity_happened_on).value).to eq Date.today.strftime("%d/%m/%Y")
        click_on 'Save activity'
        expect(page.has_content?('Activity was successfully created.')).to be true
        expect(page.has_content?(activity_type_name)).to be true
        expect(page.has_content?(Date.today.strftime("%A, %d %B %Y"))).to be true
      end

      context 'which is custom' do
        let(:custom_title) { 'Custom title' }

        let(:other_activity_type_name) { 'Exciting activity (please specify)' }
        let!(:other_activity_type) { create(:activity_type, name: other_activity_type_name, description: nil, custom: true) }

        before(:each) do
          visit activity_type_path(other_activity_type)
        end

        it 'allows a title to be added' do
          click_on 'Record this activity'
          fill_in :activity_title, with: custom_title
          fill_in_trix with: activity_description

          click_on 'Save activity'
          expect(page.has_content?('Activity was successfully created.')).to be true
          expect(page.has_content?(activity_description)).to be true
          expect(page.has_content?(other_activity_type_name)).to be false
          expect(page.has_content?(custom_title)).to be true
          expect(page.has_content?(Date.today.strftime("%A, %d %B %Y"))).to be true
        end
      end
    end
  end

  context 'as a pupil' do
    let(:pupil) { create(:pupil, school: school)}

    before(:each) do
      sign_in(pupil)
      visit activity_type_path(activity_type)
    end

    context 'viewing an activity type' do
      context 'when school is data enabled' do
        it 'should see school specific content' do
          expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to_not have_content(activity_type.description.to_plain_text)
        end

        it 'should not see prompt to login' do
          expect(page).to_not have_link("Sign in to record activity")
        end

        it 'should see prompt to record it' do
          expect(page).to have_content("Complete this activity to score your school #{activity_type.score} points!")
          expect(page).to have_link("Record this activity")
        end
      end

      context 'when school not data enabled' do
        let(:school_data_enabled) { false }

        it 'should see generic content if school if activity is data driven' do
          visit activity_type_path(activity_type)
          expect(page).to_not have_content(activity_type.school_specific_description.to_plain_text)
          expect(page).to have_content(activity_type.description.to_plain_text)
        end

        context 'when activity not data driven' do
          let(:activity_data_driven)  { false }

          it 'should see school specific content' do
            visit activity_type_path(activity_type)
            expect(page).to have_content(activity_type.school_specific_description.to_plain_text)
            expect(page).to_not have_content(activity_type.description.to_plain_text)
          end
        end
      end
    end
  end
end

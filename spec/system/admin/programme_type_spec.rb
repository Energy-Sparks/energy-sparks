require 'rails_helper'

describe 'programme type management', type: :system do

  let!(:admin)  { create(:admin) }

  describe 'managing' do

    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      click_on 'Programme Types'
    end

    it 'allows the user to create, edit and delete a programme type' do
      description = 'SPN1'
      old_title = 'Super programme number 1'
      new_title = 'Super programme number 2'
      click_on 'New Programme Type'
      fill_in 'Title', with: old_title
      fill_in_trix '#programme_type_description', with: description
      attach_file("programme_type_image", Rails.root + "spec/fixtures/images/placeholder.png")
      click_on 'Save'
      expect(page).to have_content('Programme Types')
      expect(page).to have_content(old_title)
      expect(page).to have_content('Inactive')
      expect(page).to have_content('No')

      expect(ProgrammeType.last.image.filename).to eq('placeholder.png')

      click_on 'Edit'
      fill_in 'Title', with: new_title
      check("Active", allow_label_click: true)
      check("Default", allow_label_click: true)

      click_on 'Save'
      expect(page).to have_content('Programme Types')
      expect(page).to have_content(new_title)
      expect(page).to have_content('Active')
      expect(page).to have_content('Yes')

      click_on new_title
      expect(page).to have_content(description)
      click_on 'All programme types'

      click_on 'Delete'
      expect(page).to have_content('There are no programme types')
    end

    context 'manages order' do
      let!(:activity_category)  { create(:activity_category)}
      let!(:activity_type_1)    { create(:activity_type, name: 'Turn off the lights', activity_category: activity_category) }
      let!(:activity_type_2)    { create(:activity_type, name: 'Turn down the heating', activity_category: activity_category) }
      let!(:activity_type_3)    { create(:activity_type, name: 'Turn down the cooker', activity_category: activity_category) }

      it 'assigns activity types to programme types via a text box position' do

        description = 'SPN1'
        old_title = 'Super programme number 1'

        programme_type = ProgrammeType.create(description: description, title: old_title)

        visit current_path

        click_on 'Edit activities'

        expect(page.find_field('Turn off the light').value).to be_blank
        expect(page.find_field('Turn down the heating').value).to be_blank

        fill_in 'Turn down the heating', with: '1'
        fill_in 'Turn off the lights', with: '2'

        click_on 'Update associated activity type', match: :first
        click_on old_title

        expect(programme_type.activity_types).to match_array([activity_type_2, activity_type_1])
        expect(programme_type.programme_type_activity_types.first.position).to eq(1)
        expect(programme_type.programme_type_activity_types.second.position).to eq(2)

        expect(all('ol.activities li').map(&:text)).to eq ['Turn down the heating','Turn off the lights']
      end
    end

    context 'when progammes exist for schools' do

      let!(:school)  { create(:school)}
      let!(:activity_category)  { create(:activity_category)}
      let!(:activity_type_1)    { create(:activity_type, name: 'Turn off the lights', activity_category: activity_category) }
      let!(:activity_type_2)    { create(:activity_type, name: 'Turn off the heat', activity_category: activity_category) }
      let!(:programme_type)     { create(:programme_type, title: 'Eco Worrier', activity_types: [activity_type_1, activity_type_2]) }

      before :each do
        Programmes::Enroller.new(programme_type).enrol(school)
        activity = Activity.create(school: school, activity_type: activity_type_1, title: 'Dark now', happened_on: Date.today)
        ActivityCreator.new(activity).process
        school.reload
      end

      it 'shows links to programmes' do
        visit admin_programme_types_path
        expect(page).to have_content('Eco Worrier')
        click_link '1'
        expect(page).to have_content('Eco Worrier')
        expect(page).to have_content('Total activities: 2')
        expect(page).to have_content(school.name)
        expect(page).to have_content('started')
        expect(page).to have_content('50 %')
      end
    end
  end
end

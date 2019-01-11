require 'rails_helper'

RSpec.describe "activity type", type: :system do
  let!(:admin)  { create(:user, role: 'admin')}
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

  it 'can not access it unless logged in' do
    visit new_activity_type_path
    expect(page.has_content?("Sign in")).to be true
  end

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit new_activity_type_path
      expect(ActivityType.count).to be 0
    end

    it 'can add a new activity for KS1 with filters' do
      fill_in('Name', with: 'New activity')
      first('input#activity_type_description', visible: false).set("the description")
      fill_in('Score', with: 20)
      fill_in('Badge name', with: 'Badddddger')

      check('KS1')
      check('Science')
      check('30 mins')
      check('Reducing electricity')
      check('Energy')

      click_on('Create Activity type')

      activity_type = ActivityType.first

      expect(activity_type.key_stages).to match_array([ks1])
      expect(activity_type.subjects).to   match_array([science])
      expect(activity_type.timings).to    match_array([half_hour])
      expect(activity_type.topics).to     match_array([energy])
      expect(activity_type.impacts).to    match_array([reducing_electricity])

      expect(page.has_content?("Activity type was successfully created.")).to be true
      expect(ActivityType.count).to be 1
    end

    it 'can does not crash if you forget the score' do
      fill_in('Name', with: 'New activity')
      first('input#activity_type_description', visible: false).set("the description")
      fill_in('Badge name', with: 'Badddddger')

      check('KS1')

      click_on('Create Activity type')

      expect(page.has_content?('Badddddger'))
      expect(page.has_content?("Score can't be blank"))

      expect(page.has_content?("Activity type was successfully created.")).to_not be true
      expect(ActivityType.count).to be 0
    end

    it 'can edit a new activity and add KS2 and KS3' do
      activity_type = create(:activity_type, activity_category: activity_category)
      visit edit_activity_type_path(activity_type)
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

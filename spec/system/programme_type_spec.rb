require 'rails_helper'

RSpec.describe "programme types", type: :system, include_application_helper: true do

  let!(:school) { create(:school)}
  let!(:school_admin) { create(:school_admin, school: school)}
  let!(:pupil) { create(:pupil, school: school)}

  let!(:programme_type_1) { create(:programme_type_with_activity_types)}
  let!(:programme_type_2) { create(:programme_type, active: false)}
  let!(:programme_type_3) { create(:programme_type)}

  context 'as a public user' do

    before(:each) do
      visit programme_types_path
    end

    it 'displays summary of programmes' do
      expect(page).to have_content(programme_type_1.title)
      expect(page).to have_content(programme_type_1.short_description)
    end

    it 'shows only active programme types' do
      expect(page).to have_content(programme_type_1.title)
      expect(page).to have_content(programme_type_3.title)
      expect(page).not_to have_content(programme_type_2.title)
    end

    context 'viewing a programme type' do
      before(:each) do
        click_on programme_type_1.title
      end

      it 'displays the programme overview' do
        expect(page).to have_content(programme_type_1.title)
        expect(page).to have_content(programme_type_1.short_description)
        expect(page).to have_content(programme_type_1.description.body.to_plain_text)
        expect(page).to have_link(href: programme_type_1.document_link)
      end

      it 'lists all the activities' do
        programme_type_1.activity_types.each do |at|
          expect(page).to have_link(at.name, href: activity_type_path(at))
        end
      end

      it 'does not have checklist' do
        expect(page).to_not have_css("i.fa-circle.text-muted")
        expect(page).to_not have_css("i.fa-circle.text-success")
      end

      it 'doesnt prompt to start' do
        expect(page).to_not have_content("You can enrol your school in this programme")
      end
    end
  end

  context 'as a school admin' do
    before(:each) do
      sign_in school_admin
      visit programme_types_path
    end

    context 'enrolling in a programme' do
      before(:each) do
        click_on programme_type_1.title
      end

      it 'prompts to start' do
        expect(page).to have_content("You can enrol your school in this programme")
      end

      it 'successfully enrols the school' do
        expect {
          click_link 'Start'
        }.to change(Programme, :count).from(0).to(1)
        expect(page).to have_content('You started this programme')
        expect(school.reload.programmes).not_to be_empty
      end
    end

    context 'enrolled in a programme' do
      let(:activity_type) { programme_type_1.activity_types.first }
      let(:activity)      { create(:activity, school: school, activity_type: activity_type, happened_on: Date.yesterday)}

      before(:each) do
        #this is because the Enroller relies on this currently
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
        Programmes::Enroller.new(programme_type_1).enrol(school)
        ActivityCreator.new(activity).process
        click_on programme_type_1.title
      end

      it 'says I have started' do
        expect(page).to have_content("You started this programme")
        expect(page).to have_content("Current Progress")
        expect(page).to have_content( nice_dates(school.programmes.first.started_on) )
      end

      it 'indicates I have not completed some activities' do
        expect(page).to have_css("i.fa-circle.text-muted")
      end

      it 'indicates I have completed an activity' do
        expect(page).to have_css("i.fa-check-circle.text-success")
        expect(page).to have_content( nice_dates(activity.happened_on) )
      end

      it 'doesnt link to activities that are completed' do
        expect(page).to have_content(activity_type.name)
        expect(page).to_not have_link(href: activity_type_path(activity_type))
        expect(page).to have_link(href: activity_type_path(programme_type_1.activity_types.last) )
      end

      it 'indicates I am enrolled on list of programmes' do
        click_on("View all programmes")
        expect(page).to have_content("You have already started this programme")
        expect(page).to have_link("Continue", href: programme_type_path(programme_type_1))
        expect(page).to have_link("View", href: programme_type_path(programme_type_3))
      end
    end
  end

  context 'as a pupil' do
    before(:each) do
      sign_in pupil
      visit programme_types_path
    end

    context 'enrolling in a programme' do
      before(:each) do
        click_on programme_type_1.title
      end

      it 'prompts to start' do
        expect(page).to have_content("You can enrol your school in this programme")
      end

      it 'successfully enrols the school' do
        expect {
          click_link 'Start'
        }.to change(Programme, :count).from(0).to(1)
        expect(page).to have_content('You started this programme')
        expect(school.reload.programmes).not_to be_empty
      end
    end

    context 'enrolled in a programme' do
      let(:activity_type) { programme_type_1.activity_types.first }
      let(:activity)      { create(:activity, school: school, activity_type: activity_type, happened_on: Date.yesterday)}

      before(:each) do
        #this is because the Enroller relies on this currently
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
        Programmes::Enroller.new(programme_type_1).enrol(school)
        ActivityCreator.new(activity).process
        click_on programme_type_1.title
      end

      it 'says I have started' do
        expect(page).to have_content("You started this programme")
        expect(page).to have_content("Current Progress")
        expect(page).to have_content( nice_dates(school.programmes.first.started_on) )
      end

      it 'indicates I have not completed some activities' do
        expect(page).to have_css("i.fa-circle.text-muted")
      end

      it 'indicates I have completed an activity' do
        expect(page).to have_css("i.fa-check-circle.text-success")
        expect(page).to have_content( nice_dates(activity.happened_on) )
      end

      it 'doesnt link to activities that are completed' do
        expect(page).to have_content(activity_type.name)
        expect(page).to_not have_link(href: activity_type_path(activity_type))
        expect(page).to have_link(href: activity_type_path(programme_type_1.activity_types.last) )
      end

      it 'indicates I am enrolled on list of programmes' do
        click_on("View all programmes")
        expect(page).to have_content("You have already started this programme")
        expect(page).to have_link("Continue", href: programme_type_path(programme_type_1))
        expect(page).to have_link("View", href: programme_type_path(programme_type_3))
      end
    end
  end
end

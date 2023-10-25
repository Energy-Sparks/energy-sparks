require 'rails_helper'

describe 'Recommendations Page', type: :system, include_application_helper: true do
  let!(:school) { create :school, name: "School Name" }
  let!(:setup_data) {}

  before do
    # later we should simulate navigating here
    visit school_recommendations_url(school)
  end

  it_behaves_like "a page with breadcrumbs", ['Schools', 'School Name', 'Recommended activities & actions']

  it "has the title" do
    within("h1") do
      expect(page).to have_content("Recommended activities & actions")
    end
  end

  it "has the intro" do
    expect(page).to have_content("Find your next energy saving activity to score points for your school, reduce your energy usage and learn more about energy and climate change")
  end

  context "with prompts" do
    context "programme prompt" do
      let(:programme_type) { create(:programme_type_with_activity_types, bonus_score: 12) }
      let(:setup_data) { create(:programme, programme_type: programme_type, started_on: Time.zone.today, school: school) }

      it "has prompts to complete programmes" do
        expect(page).to have_content("You have completed 0/3 of the activities in the #{programme_type.title} programme. Complete the final 3 activities now to score 75 points and 12 bonus points for completing the programme")
      end
    end

    context "audit prompt" do
      let(:setup_data) do
        SiteSettings.create!(audit_activities_bonus_points: 50)
        create(:audit, :with_activity_and_intervention_types, school: school)
      end

      it "has prompt to complete audit actions and activities" do
        expect(page).to have_content("You have completed 0/3 of the activities and 0/3 of the actions from your recent energy audit. Complete the others to score 165 points and 50 bonus points for completing all audit tasks")
      end
    end
  end

  context "more ideas section" do
    let(:section) { find(:css, '#more-ideas') }

    it "has a title" do
      expect(section).to have_content("More ideas")
    end

    it "has description" do
      expect(section).to have_content("Looking for more ideas? Explore some of these options")
    end

    it "has a link to programmes" do
      expect(section).to have_link(href: '/programme_types')
    end

    it "has a link to activities" do
      expect(section).to have_link(href: '/activity_categories')
    end

    it "has a link to actions" do
      expect(section).to have_link(href: '/intervention_type_groups')
    end

    it "has a link to schools advice page" do
      expect(section).to have_link(href: "/schools/#{school.slug}/advice")
    end
  end
end

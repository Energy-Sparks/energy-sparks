require 'rails_helper'

describe 'Recommendations Page', type: :system, include_application_helper: true do
  let!(:school) { create :school, name: "School Name" }

  before do
    # later we should simulate navigating here
    visit school_recommendations_url(school)
  end

  it_behaves_like "a page with breadcrumbs", ['Schools', 'School Name', 'Recommended Activities']

  it "has the title" do
    within("h1") do
      expect(page).to have_content("Recommended Activities")
    end
  end

  it "has the intro" do
    expect(page).to have_content("Find your next energy saving activity to score points for your school, reduce your energy usage and learn more about energy and climate change")
  end

  context "more ideas section" do
    let(:section) { find(:css, '#more-ideas') }

    it "has a title" do
      expect(section).to have_content("More ideas")
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

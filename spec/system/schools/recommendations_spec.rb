require 'rails_helper'

describe 'Recommendations Page', type: :system  do
  let!(:school) { create :school, name: "School Name" }

  before do
    # later we should simulate navigating here
    visit school_recommendations_url(school)
  end

  it_behaves_like "a page with breadcrumbs", ['Schools', 'School Name', 'Recommended Pupil Activities & Adult Actions']

  it "has the title" do
    within("h1") do
      expect(page).to have_content("Recommended Pupil Activities & Adult Actions")
    end
  end

  it "has the intro" do
    expect(page).to have_content("Find your next energy saving activity to score points for your school, reduce your energy usage and learn more about energy and climate change")
  end
end
